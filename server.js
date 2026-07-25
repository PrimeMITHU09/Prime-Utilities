const http = require('http');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const PORT = process.env.PORT || 3000;
const PUBLIC_DIR = __dirname;

const MIME_TYPES = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'text/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon'
};

const server = http.createServer((req, res) => {
  // CORS Headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // API Endpoint: Run PowerShell Script
  if (req.url === '/api/run-command' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => { body += chunk.toString(); });
    req.on('end', () => {
      try {
        const { script } = JSON.parse(body);
        if (!script) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'No script provided' }));
          return;
        }

        console.log('[API] Executing generated PowerShell script...');
        
        // Write temporary execution script
        const tempScriptPath = path.join(__dirname, 'temp_exec.ps1');
        fs.writeFileSync(tempScriptPath, script);

        // Spawn PowerShell process
        const ps = spawn('powershell.exe', [
          '-NoProfile',
          '-ExecutionPolicy', 'Bypass',
          '-File', tempScriptPath
        ]);

        let output = '';
        ps.stdout.on('data', (data) => {
          const str = data.toString();
          output += str;
          console.log('[PS STDOUT]', str);
        });

        ps.stderr.on('data', (data) => {
          const str = data.toString();
          output += str;
          console.error('[PS STDERR]', str);
        });

        ps.on('close', (code) => {
          // Cleanup temp script
          if (fs.existsSync(tempScriptPath)) {
            try { fs.unlinkSync(tempScriptPath); } catch (e) {}
          }

          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({
            success: code === 0,
            exitCode: code,
            output: output || 'Execution completed.'
          }));
        });

      } catch (err) {
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  // Static File Serving
  let filePath = path.join(PUBLIC_DIR, req.url === '/' ? 'index.html' : req.url);
  const ext = path.extname(filePath);
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';

  fs.readFile(filePath, (err, content) => {
    if (err) {
      if (err.code === 'ENOENT') {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('404 Not Found');
      } else {
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end(`Server Error: ${err.code}`);
      }
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content, 'utf-8');
    }
  });
});

server.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(` PRIME UTILITIES LOCAL SERVER RUNNING ON PORT ${PORT}`);
  console.log(` Dashboard URL: http://localhost:${PORT}`);
  console.log(`====================================================`);
});
