require('dotenv').config();
const express  = require('express');
const http     = require('http');
const { Server } = require('socket.io');
const cors     = require('cors');
const { RoomManager } = require('./roomManager');

const app    = express();
const server = http.createServer(app);
const PORT   = process.env.PORT || 3000;

// ── CORS ───────────────────────────────────────────────────────────────────
const allowedOrigins = [
  process.env.FRONTEND_URL,
  'http://localhost:8080',
  'http://localhost:3000',
].filter(Boolean);

app.use(cors({ origin: allowedOrigins, credentials: true }));
app.use(express.json());

// ── Socket.io ──────────────────────────────────────────────────────────────
const io = new Server(server, {
  cors: { origin: allowedOrigins, methods: ['GET', 'POST'] },
  pingTimeout: 60000,
});

const rooms = new RoomManager();

io.on('connection', (socket) => {
  console.log(`[+] Connected: ${socket.id}`);

  // ── Create room ─────────────────────────────────────────────────────────
  socket.on('create_room', ({ playerName, bootAmount = 10 }, cb) => {
    const room = rooms.create({ bootAmount });
    rooms.addPlayer(room.code, { id: socket.id, name: playerName });
    socket.join(room.code);
    console.log(`Room ${room.code} created by ${playerName}`);
    cb?.({ success: true, roomCode: room.code });
  });

  // ── Join room ────────────────────────────────────────────────────────────
  socket.on('join_room', ({ roomCode, playerName }, cb) => {
    const room = rooms.get(roomCode);
    if (!room) return cb?.({ success: false, error: 'Room not found' });
    if (room.players.length >= 6) return cb?.({ success: false, error: 'Room full' });

    rooms.addPlayer(roomCode, { id: socket.id, name: playerName });
    socket.join(roomCode);
    io.to(roomCode).emit('room_update', rooms.getPublicState(roomCode));
    cb?.({ success: true });
  });

  // ── Start game ───────────────────────────────────────────────────────────
  socket.on('start_game', ({ roomCode }) => {
    const room = rooms.get(roomCode);
    if (!room || room.players.length < 2) return;
    rooms.startRound(roomCode);
    io.to(roomCode).emit('round_started', rooms.getPublicState(roomCode));
  });

  // ── Player action ────────────────────────────────────────────────────────
  socket.on('player_action', ({ roomCode, action }) => {
    const result = rooms.handleAction(roomCode, socket.id, action);
    if (!result) return;

    if (result.roundOver) {
      io.to(roomCode).emit('round_over', result);
    } else {
      io.to(roomCode).emit('game_state', rooms.getPublicState(roomCode));
    }
  });

  // ── Disconnect ───────────────────────────────────────────────────────────
  socket.on('disconnect', () => {
    console.log(`[-] Disconnected: ${socket.id}`);
    rooms.removePlayer(socket.id);
  });
});

// ── REST health check ──────────────────────────────────────────────────────
app.get('/health', (_, res) => res.json({ status: 'ok', rooms: rooms.count() }));

// ── Start ──────────────────────────────────────────────────────────────────
server.listen(PORT, () => {
  console.log(`🃏 Teen Patti server running on port ${PORT}`);
});

module.exports = { app, server };
