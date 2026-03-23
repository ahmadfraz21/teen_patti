const { v4: uuidv4 } = require('uuid');

// ── Card / deck utils ──────────────────────────────────────────────────────
const SUITS  = ['♠','♥','♦','♣'];
const RANKS  = ['2','3','4','5','6','7','8','9','10','J','Q','K','A'];
const RANK_VALUES = Object.fromEntries(RANKS.map((r, i) => [r, i + 2]));

function buildDeck() {
  const deck = [];
  for (const suit of SUITS)
    for (const rank of RANKS)
      deck.push({ rank, suit, value: RANK_VALUES[rank], label: `${rank}${suit}` });
  return deck;
}

function shuffle(arr) {
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

// ── Hand evaluator ─────────────────────────────────────────────────────────
function evaluateHand(hand) {
  const sorted = [...hand].sort((a, b) => b.value - a.value);
  const v      = sorted.map(c => c.value);
  const isFlush = hand.every(c => c.suit === hand[0].suit);
  const isSeq   = (v[0]-v[1]===1 && v[1]-v[2]===1) || (v[0]===14 && v[1]===3 && v[2]===2);

  if (v[0]===v[1] && v[1]===v[2]) return { rank: 5, tiebreakers: [v[0]], label: `Trail (${sorted[0].rank}s)` };
  if (isFlush && isSeq)            return { rank: 4, tiebreakers: v, label: `Pure Sequence` };
  if (isSeq)                       return { rank: 3, tiebreakers: v, label: `Sequence` };
  if (isFlush)                     return { rank: 2, tiebreakers: v, label: `Flush` };
  if (v[0]===v[1])                 return { rank: 1, tiebreakers: [v[0], v[2]], label: `Pair of ${sorted[0].rank}s` };
  if (v[1]===v[2])                 return { rank: 1, tiebreakers: [v[1], v[0]], label: `Pair of ${sorted[1].rank}s` };
  return { rank: 0, tiebreakers: v, label: `High Card (${sorted[0].rank})` };
}

function compareHands(a, b) {
  if (a.rank !== b.rank) return a.rank - b.rank;
  for (let i = 0; i < a.tiebreakers.length; i++) {
    if (a.tiebreakers[i] !== b.tiebreakers[i]) return a.tiebreakers[i] - b.tiebreakers[i];
  }
  return 0;
}

// ── Room Manager ───────────────────────────────────────────────────────────
class RoomManager {
  constructor() {
    this._rooms = new Map(); // roomCode → room
    this._playerRoom = new Map(); // socketId → roomCode
  }

  count() { return this._rooms.size; }

  create({ bootAmount = 10 } = {}) {
    const code = Math.random().toString(36).slice(2, 7).toUpperCase();
    const room = {
      code,
      bootAmount,
      players: [],        // { id, name, chips, hand, status, isSeen, betInRound }
      pot: 0,
      currentBet: bootAmount,
      turnIndex: 0,
      phase: 'idle',
    };
    this._rooms.set(code, room);
    return room;
  }

  get(code) { return this._rooms.get(code) ?? null; }

  addPlayer(code, { id, name }) {
    const room = this.get(code);
    if (!room) return;
    room.players.push({ id, name, chips: 1000, hand: [], status: 'waiting', isSeen: false, betInRound: 0 });
    this._playerRoom.set(id, code);
  }

  removePlayer(socketId) {
    const code = this._playerRoom.get(socketId);
    if (!code) return;
    const room = this.get(code);
    if (room) {
      room.players = room.players.filter(p => p.id !== socketId);
      if (room.players.length === 0) this._rooms.delete(code);
    }
    this._playerRoom.delete(socketId);
  }

  startRound(code) {
    const room = this.get(code);
    if (!room) return;

    const deck = shuffle(buildDeck());
    room.pot = 0;
    room.currentBet = room.bootAmount;
    room.turnIndex = 0;
    room.phase = 'betting';

    for (const p of room.players) {
      p.hand = deck.splice(0, 3);
      p.status = 'active';
      p.isSeen = false;
      p.betInRound = 0;
      const paid = Math.min(room.bootAmount, p.chips);
      p.chips -= paid;
      p.betInRound += paid;
      room.pot += paid;
    }
  }

  handleAction(code, socketId, action) {
    const room = this.get(code);
    if (!room || room.phase !== 'betting') return null;

    const player = room.players[room.turnIndex];
    if (player.id !== socketId) return null;

    switch (action) {
      case 'fold':
        player.status = 'folded';
        break;

      case 'blind': {
        const amount = player.isSeen ? room.currentBet : Math.max(room.bootAmount, room.currentBet / 2);
        const paid   = Math.min(amount, player.chips);
        player.chips -= paid; player.betInRound += paid; room.pot += paid;
        break;
      }

      case 'seen': {
        if (!player.isSeen) player.isSeen = true;
        const paid = Math.min(room.currentBet, player.chips);
        player.chips -= paid; player.betInRound += paid; room.pot += paid;
        break;
      }

      case 'show': {
        const active = room.players.filter(p => p.status === 'active');
        if (active.length !== 2) return null;
        if (!player.isSeen) player.isSeen = true;
        return this._resolveShowdown(room);
      }
    }

    // Check if only one player left
    const active = room.players.filter(p => p.status === 'active');
    if (active.length === 1) {
      active[0].chips += room.pot;
      return { roundOver: true, winner: active[0].name, potWon: room.pot, reason: 'All others folded' };
    }

    // Advance turn
    this._advanceTurn(room);
    return null;
  }

  _resolveShowdown(room) {
    const active = room.players.filter(p => p.status === 'active');
    let best = active[0];
    let bestResult = evaluateHand(best.hand);

    for (const p of active.slice(1)) {
      const result = evaluateHand(p.hand);
      if (compareHands(result, bestResult) > 0) { best = p; bestResult = result; }
    }

    best.chips += room.pot;
    room.phase = 'idle';
    return { roundOver: true, winner: best.name, potWon: room.pot, winnerHand: bestResult.label, reason: 'Showdown' };
  }

  _advanceTurn(room) {
    let next = (room.turnIndex + 1) % room.players.length;
    let attempts = 0;
    while (room.players[next].status !== 'active' && attempts < room.players.length) {
      next = (next + 1) % room.players.length;
      attempts++;
    }
    room.turnIndex = next;
  }

  // Public state (hides hand cards from other players)
  getPublicState(code) {
    const room = this.get(code);
    if (!room) return null;
    return {
      code: room.code,
      pot: room.pot,
      currentBet: room.currentBet,
      phase: room.phase,
      turnIndex: room.turnIndex,
      players: room.players.map(p => ({
        id: p.id,
        name: p.name,
        chips: p.chips,
        status: p.status,
        isSeen: p.isSeen,
        betInRound: p.betInRound,
        cardCount: p.hand.length,
      })),
    };
  }
}

module.exports = { RoomManager };
