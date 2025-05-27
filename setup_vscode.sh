#!/bin/bash

# Define VS Code config directory
VSCODE_DIR=".vscode"
mkdir -p "$VSCODE_DIR"

# Detect OpenFOAM base path (fallback if not set)
FOAM_BASE="${WM_PROJECT_DIR:-/opt/openfoam}"

# Create settings.json
cat <<EOF > "$VSCODE_DIR/settings.json"
{
  "files.associations": {
    "*.dict": "json",
    "*.foam": "cpp"
  },
  "editor.formatOnSave": true,
  "terminal.integrated.env.linux": {
    "FOAM_RUN": "\${env:FOAM_RUN}",
    "FOAM_SRC": "\${env:FOAM_SRC}",
    "PATH": "\${env:PATH}"
  },
  "C_Cpp.default.configurationProvider": "ms-vscode.cmake-tools"
}
EOF

# Create tasks.json
cat <<EOF > "$VSCODE_DIR/tasks.json"
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Compile OpenFOAM Solver",
      "type": "shell",
      "command": "wmake",
      "problemMatcher": []
    },
    {
      "label": "Run OpenFOAM Case",
      "type": "shell",
      "command": "simpleFoam",
      "problemMatcher": []
    },
    {
      "label": "Reconstruct Parallel Data",
      "type": "shell",
      "command": "reconstructPar",
      "problemMatcher": []
    }
  ]
}
EOF

# Create launch.json
cat <<EOF > "$VSCODE_DIR/launch.json"
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug OpenFOAM Solver",
      "type": "cppdbg",
      "request": "launch",
      "program": "\${workspaceFolder}/applications/bin/simpleFoam",
      "args": [],
      "stopAtEntry": false,
      "cwd": "\${workspaceFolder}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "gdb",
      "setupCommands": [
        {
          "description": "Enable pretty-printing for gdb",
          "text": "-enable-pretty-printing",
          "ignoreFailures": true
        }
      ],
      "preLaunchTask": "Compile OpenFOAM Solver"
    }
  ]
}
EOF

# Create c_cpp_properties.json
cat <<EOF > "$VSCODE_DIR/c_cpp_properties.json"
{
  "configurations": [
    {
      "name": "WSL-Ubuntu",
      "compilerPath": "/usr/bin/gcc",
      "includePath": [
        "$FOAM_BASE/include",
        "$FOAM_BASE/src",
        "\${workspaceFolder}/src/**"
      ],
      "defines": [],
      "cStandard": "c11",
      "cppStandard": "c++17",
      "intelliSenseMode": "linux-gcc-x64"
    }
  ],
  "version": 4
}
EOF

# Create extensions.json
cat <<EOF > "$VSCODE_DIR/extensions.json"
{
  "recommendations": [
    "ms-vscode.cpptools",
    "ms-vscode.cmake-tools",
    "timonwong.shellcheck",
    "jeff-hykin.better-cpp-syntax"
  ]
}
EOF

echo "✅ VS Code configuration generated successfully for WSL2 + OpenFOAM!"
