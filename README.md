<font color="red">For the information on the competition from 2022, please see [this page](https://github.com/TeamFightingICE/FightingICE/tree/master/DareFightingICE).</font>

# FightingICE #

This repository is a repository for the development of the 2D fighting game FightingICE, which is used in international competitions for fighting game AI performance.<br>

### About FightingICE ###
FightingICE is a 2D fighting game used in the Fighting Game AI Competition (FTGAIC), an international competition that competes for the performance of fighting game AI certified by Computational Intelligence and Games (CIG).

---

## Getting Started on Linux

### Prerequisites
- **Java 21 or higher** (OpenJDK recommended)
- **Protocol Buffers compiler** (protoc)
- **Graphics libraries** (OpenGL, X11)
- **Python 3** (optional, for Python AI clients)

### Quick Setup

#### 1. Run the Setup Script
The setup script will automatically check and install all required dependencies:

```bash
./setup-linux.sh
```

This script will:
- ✓ Check for Java 21+ and install if missing
- ✓ Install Protocol Buffers compiler
- ✓ Install required graphics libraries (OpenGL, X11, etc.)
- ✓ Install Python dependencies (if requirements.txt exists)
- ✓ Make build and run scripts executable

#### 2. Build the Game
After setup is complete, compile the game:

```bash
./build-linux.sh
```

This will:
- Generate Protocol Buffers files for Java and Python
- Compile all Java source files
- Output compiled classes to the `bin` directory

#### 3. Run the Game
Launch FightingICE:

```bash
./run-linux.sh
```

You can also pass additional arguments:
```bash
./run-linux.sh [arguments]
```

---

## Python Development

### Setting Up Python Environment

The project includes Python components for AI clients and the Twitch extension. It's recommended to use a virtual environment.

#### 1. Activate Virtual Environment
If you ran `./setup-linux.sh`, a virtual environment was created at `./venv`. Activate it:

```bash
source venv/bin/activate
```

You should see `(venv)` in your terminal prompt.

#### 2. Manual Virtual Environment Creation
If you need to create a virtual environment manually:

```bash
# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

#### 3. Running Python Scripts

**Demo Event Injector:**
```bash
source venv/bin/activate
python src_python/demo_event.py
```

**Twitch Extension Server:**
```bash
source venv/bin/activate
python Twitch-extension/python_server_deploy.py
```

**Custom AI Scripts:**
```bash
source venv/bin/activate
python your_ai_script.py
```

#### 4. Deactivate Virtual Environment
When done:

```bash
deactivate
```

### Python Dependencies

The project uses:
- `protobuf>=4.21.0` - Protocol Buffers for game communication
- `aiohttp>=3.9.0` - Async HTTP server (Twitch extension)
- `aiohttp-cors>=0.7.0` - CORS support
- `twitchio>=2.5.0,<2.9.0` - Twitch chat integration
- `certifi>=2023.7.22` - SSL certificate handling

See [requirements.txt](requirements.txt) for the complete list.

