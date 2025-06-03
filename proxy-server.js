const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();
const PORT = 3001;

// Enable CORS for all routes
app.use(cors({
  origin: ['http://localhost:8080', 'http://127.0.0.1:8080'],
  credentials: true
}));

// Proxy middleware for AstroYorumAI API
const apiProxy = createProxyMiddleware({
  target: 'https://astroyorumai-api.onrender.com',
  changeOrigin: true,
  pathRewrite: {
    '^/api': '', // remove /api prefix when forwarding to target
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log(`Proxying ${req.method} ${req.url} to target`);
  },
  onProxyRes: (proxyRes, req, res) => {
    console.log(`Received response ${proxyRes.statusCode} for ${req.url}`);
  },
  onError: (err, req, res) => {
    console.error('Proxy error:', err);
    res.status(500).send('Proxy error occurred');
  }
});

// Use the proxy for all /api routes
app.use('/api', apiProxy);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'AstroYorumAI Proxy Server Running' });
});

app.listen(PORT, () => {
  console.log(`🚀 AstroYorumAI Proxy Server running on http://localhost:${PORT}`);
  console.log(`📡 Proxying requests to: https://astroyorumai-api.onrender.com`);
  console.log(`🌐 Use http://localhost:${PORT}/api/natal instead of direct API calls`);
});
