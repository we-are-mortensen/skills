#!/usr/bin/env node
// Mortensen Skills CLI — thin wrapper that runs the interactive bash installer.
// Usage:
//   npx github:we-are-mortensen/skills
//   npx github:we-are-mortensen/skills mortensen-design

const { spawn } = require("node:child_process");
const path = require("node:path");
const fs = require("node:fs");

const installer = path.resolve(__dirname, "..", "install.sh");

if (!fs.existsSync(installer)) {
  console.error("✗ install.sh not found at", installer);
  process.exit(1);
}

const args = process.argv.slice(2);
const child = spawn("bash", [installer, ...args], { stdio: "inherit" });

child.on("exit", (code) => process.exit(code ?? 0));
child.on("error", (err) => {
  console.error("✗ Failed to start installer:", err.message);
  process.exit(1);
});
