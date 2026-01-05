#!/bin/bash

echo "======================================"
echo "FightingICE Linux Setup Script"
echo "======================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${YELLOW}Warning: Running as root. This script will install packages system-wide.${NC}"
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to generate requirements.txt
generate_requirements() {
    echo "# FightingICE Python Dependencies" > requirements.txt
    echo "" >> requirements.txt
    echo "# Protocol Buffers - for game communication" >> requirements.txt
    echo "protobuf>=4.21.0" >> requirements.txt
    echo "" >> requirements.txt
    echo "# Twitch Integration (optional - for Twitch extension)" >> requirements.txt
    echo "certifi>=2023.7.22" >> requirements.txt
    echo "aiohttp>=3.9.0" >> requirements.txt
    echo "aiohttp-cors>=0.7.0" >> requirements.txt
    echo "twitchio>=2.9.0" >> requirements.txt
    echo -e "${GREEN}✓ Generated requirements.txt${NC}"
}

# Check Java version
echo "Checking Java installation..."
REQUIRED_JAVA_VERSION="21.0.9"

if command_exists java && command_exists javac; then
    JAVA_VERSION=$(java --version 2>&1 | head -n 1 | awk '{print $2}')
    JAVAC_VERSION=$(javac --version 2>&1 | awk '{print $2}')
    
    echo -e "${GREEN}✓ Java found:${NC}"
    echo "  Java Runtime: $JAVA_VERSION"
    echo "  Java Compiler: $JAVAC_VERSION"
    
    # Check for exact version match
    if [ "$JAVA_VERSION" = "$REQUIRED_JAVA_VERSION" ] && [ "$JAVAC_VERSION" = "$REQUIRED_JAVA_VERSION" ]; then
        echo -e "${GREEN}✓ Java version matches required version ($REQUIRED_JAVA_VERSION)${NC}"
        INSTALL_JAVA=false
    else
        echo -e "${YELLOW}! Java version mismatch:${NC}"
        echo "  Required: $REQUIRED_JAVA_VERSION"
        echo "  Found: $JAVA_VERSION"
        echo ""
        read -p "Do you want to install/update to Java $REQUIRED_JAVA_VERSION? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            INSTALL_JAVA=true
        else
            echo -e "${YELLOW}⚠ Continuing with current Java version. The application may not work correctly.${NC}"
            INSTALL_JAVA=false
        fi
    fi
else
    echo -e "${RED}✗ Java not found${NC}"
    echo ""
    read -p "Do you want to install Java $REQUIRED_JAVA_VERSION? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_JAVA=true
    else
        echo -e "${RED}Error: Java is required to run this application.${NC}"
        exit 1
    fi
fi

# Install Java if needed
if [ "$INSTALL_JAVA" = true ]; then
    echo ""
    echo "Installing OpenJDK 21..."
    echo -e "${YELLOW}Note: This will install the latest OpenJDK 21 available in your distribution.${NC}"
    echo "      For exact version $REQUIRED_JAVA_VERSION, you may need to install manually."
    echo ""
    
    if command_exists apt-get; then
        # Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install -y openjdk-21-jdk
    elif command_exists dnf; then
        # Fedora
        sudo dnf install -y java-21-openjdk java-21-openjdk-devel
    elif command_exists yum; then
        # CentOS/RHEL
        sudo yum install -y java-21-openjdk java-21-openjdk-devel
    elif command_exists pacman; then
        # Arch Linux
        sudo pacman -S --noconfirm jdk21-openjdk
    else
        echo -e "${RED}Error: Could not detect package manager.${NC}"
        echo "Please install OpenJDK 21.0.9 manually from:"
        echo "  - https://jdk.java.net/21/"
        echo "  - Or use SDKMAN: curl -s \"https://get.sdkman.io\" | bash"
        echo "  - Then: sdk install java 21.0.9-open"
        exit 1
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ OpenJDK 21 installed successfully${NC}"
        NEW_JAVA_VERSION=$(java --version 2>&1 | head -n 1 | awk '{print $2}')
        echo "  Installed version: $NEW_JAVA_VERSION"
        
        if [ "$NEW_JAVA_VERSION" != "$REQUIRED_JAVA_VERSION" ]; then
            echo -e "${YELLOW}⚠ Installed version does not match required version exactly.${NC}"
            echo "  Consider using SDKMAN or manual installation for exact version:"
            echo "  https://jdk.java.net/archive/"
        fi
    else
        echo -e "${RED}✗ Failed to install OpenJDK 21${NC}"
        exit 1
    fi
fi

# Check for Protocol Buffers compiler
echo ""
echo "Checking Protocol Buffers compiler..."
if command_exists protoc; then
    PROTOC_VERSION=$(protoc --version 2>&1 | awk '{print $2}')
    echo -e "${GREEN}✓ protoc found: $PROTOC_VERSION${NC}"
else
    echo -e "${YELLOW}! protoc not found. Installing...${NC}"
    
    if command_exists apt-get; then
        sudo apt-get install -y protobuf-compiler
    elif command_exists dnf; then
        sudo dnf install -y protobuf-compiler
    elif command_exists yum; then
        sudo yum install -y protobuf-compiler
    elif command_exists pacman; then
        sudo pacman -S --noconfirm protobuf
    else
        echo -e "${RED}Error: Could not detect package manager. Please install protobuf-compiler manually.${NC}"
        exit 1
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ protoc installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install protoc${NC}"
        exit 1
    fi
fi

# Build first to generate Protocol Buffer files
echo ""
echo "Building project to generate Protocol Buffer files..."
if [ -f "./build-linux.sh" ]; then
    chmod +x build-linux.sh
    ./build-linux.sh
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Build completed successfully${NC}"
    else
        echo -e "${YELLOW}! Build had some issues, but continuing...${NC}"
    fi
else
    echo -e "${YELLOW}! build-linux.sh not found, skipping build${NC}"
fi

# Check for Python (optional, for Python client)
echo ""
echo "Checking Python installation (optional for Python AI clients)..."
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    PYTHON_PATH=$(which python3)
    echo -e "${GREEN}✓ Python 3 found: $PYTHON_VERSION${NC}"
    echo "  Python path: $PYTHON_PATH"
    
    # Check if ./venv already exists
    if [ -d "./venv" ] && [ -f "./venv/bin/activate" ]; then
        echo -e "${GREEN}✓ Found existing virtual environment at ./venv${NC}"
        echo "Activating virtual environment..."
        source ./venv/bin/activate
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Virtual environment activated${NC}"
            echo "  Virtual environment: $VIRTUAL_ENV"
            IN_VENV=true
        else
            echo -e "${RED}✗ Failed to activate existing virtual environment${NC}"
            echo "You may need to recreate it:"
            echo "  ${YELLOW}rm -rf venv${NC}"
            echo "  ${YELLOW}python3 -m venv venv${NC}"
            echo "  ${YELLOW}source venv/bin/activate${NC}"
            exit 1
        fi
    # Check if running in a virtual environment
    elif [ -n "$VIRTUAL_ENV" ]; then
        echo -e "${GREEN}✓ Virtual environment detected: $VIRTUAL_ENV${NC}"
        IN_VENV=true
        VENV_PATH="$VIRTUAL_ENV"
    else
        # Check if this is system Python
        if [[ "$PYTHON_PATH" == "/usr/bin/python3" ]] || [[ "$PYTHON_PATH" == "/bin/python3" ]]; then
            echo -e "${YELLOW}⚠ WARNING: Using system Python${NC}"
            echo ""
            echo -e "${YELLOW}It is STRONGLY RECOMMENDED to use a virtual environment!${NC}"
            echo ""
            read -p "Do you want to create a virtual environment now? (y/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Check if python3-venv is installed
                echo "Checking for python3-venv package..."
                if ! dpkg -l | grep -q python3.*-venv 2>/dev/null && ! python3 -m venv --help >/dev/null 2>&1; then
                    echo -e "${YELLOW}! python3-venv not found. Installing...${NC}"
                    
                    if command_exists apt-get; then
                        # Get Python version to install correct venv package
                        PYTHON_VER=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1,2)
                        sudo apt-get update
                        sudo apt-get install -y python3-venv python${PYTHON_VER}-venv 2>/dev/null || sudo apt-get install -y python3-venv
                        
                        if [ $? -ne 0 ]; then
                            echo -e "${RED}✗ Failed to install python3-venv${NC}"
                            echo "Please install manually: ${YELLOW}sudo apt-get install python3-venv${NC}"
                            exit 1
                        fi
                        echo -e "${GREEN}✓ python3-venv installed${NC}"
                    else
                        echo -e "${RED}✗ Cannot auto-install python3-venv${NC}"
                        echo "Please install it manually: ${YELLOW}sudo apt-get install python3-venv${NC}"
                        exit 1
                    fi
                fi
                
                echo "Creating virtual environment in ./venv..."
                python3 -m venv --clear venv
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✓ Virtual environment created${NC}"
                    echo ""
                    
                    # Clean up any system package references that leaked through
                    echo "Ensuring isolated environment..."
                    
                    echo "Activating virtual environment..."
                    source venv/bin/activate
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}✓ Virtual environment activated${NC}"
                        echo "  Virtual environment: $VIRTUAL_ENV"
                        IN_VENV=true
                        # Continue with the rest of the script
                    else
                        echo -e "${RED}✗ Failed to activate virtual environment${NC}"
                        echo "Please activate manually and run this script again:"
                        echo "  ${YELLOW}source venv/bin/activate${NC}"
                        echo "  ${YELLOW}./setup-linux.sh${NC}"
                        exit 1
                    fi
                else
                    echo -e "${RED}✗ Failed to create virtual environment${NC}"
                    exit 1
                fi
            else
                echo ""
                read -p "Do you want to continue with system Python anyway? (y/n): " -n 1 -r
                echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    echo -e "${YELLOW}Please set up a virtual environment and run this script again:${NC}"
                    echo "  ${YELLOW}python3 -m venv venv${NC}"
                    echo "  ${YELLOW}source venv/bin/activate${NC}"
                    echo "  ${YELLOW}./setup-linux.sh${NC}"
                    exit 1
                fi
                IN_VENV=false
            fi
        else
            echo -e "${GREEN}✓ Appears to be using a virtual environment or custom Python installation${NC}"
            IN_VENV=true
        fi
    fi
    
    # Update .gitignore
    echo ""
    echo "Updating .gitignore..."
    if [ -f ".gitignore" ]; then
        if ! grep -q "^venv/" .gitignore 2>/dev/null; then
            echo "venv/" >> .gitignore
            echo "__pycache__/" >> .gitignore
            echo "*.pyc" >> .gitignore
            echo -e "${GREEN}✓ Added venv to .gitignore${NC}"
        else
            echo -e "${GREEN}✓ .gitignore already configured${NC}"
        fi
    else
        echo "venv/" > .gitignore
        echo "__pycache__/" >> .gitignore
        echo "*.pyc" >> .gitignore
        echo -e "${GREEN}✓ Created .gitignore${NC}"
    fi
    
    # Generate requirements.txt
    echo ""
    echo "Generating requirements.txt..."
    generate_requirements
    
    # Check for pip
    if command_exists pip3 || command_exists pip; then
        PIP_CMD=$(command_exists pip && echo "pip" || echo "pip3")
        echo -e "${GREEN}✓ pip found${NC}"
        
        # Install dependencies
        echo ""
        echo "Installing Python dependencies from requirements.txt..."
        
        if [ "$IN_VENV" = false ]; then
            echo -e "${YELLOW}⚠ Installing to system Python (not recommended)${NC}"
        fi
        
        $PIP_CMD install -r requirements.txt
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Python dependencies installed${NC}"
        else
            echo -e "${YELLOW}! Failed to install some Python dependencies${NC}"
            echo "  You can try manually: pip3 install -r requirements.txt"
        fi
    else
        echo -e "${YELLOW}! pip not found. Install it if you plan to use Python AI clients.${NC}"
        echo "  Install: sudo apt-get install python3-pip"
    fi
else
    echo -e "${YELLOW}! Python 3 not found. Install it if you plan to use Python AI clients.${NC}"
    echo "  Install: sudo apt-get install python3 python3-venv python3-pip"
fi

# Check for required libraries (for LWJGL)
echo ""
echo "Checking system libraries for graphics support..."
MISSING_LIBS=false

if command_exists ldconfig; then
    # Check for common graphics libraries needed by LWJGL
    for lib in libGL.so libGLU.so libX11.so libXxf86vm.so libXrandr.so libXi.so; do
        if ! ldconfig -p | grep -q $lib; then
            echo -e "${YELLOW}! Missing library: $lib${NC}"
            MISSING_LIBS=true
        fi
    done
    
    if [ "$MISSING_LIBS" = true ]; then
        echo ""
        echo "Installing required graphics libraries..."
        if command_exists apt-get; then
            sudo apt-get install -y libgl1-mesa-glx libglu1-mesa libx11-6 libxxf86vm1 libxrandr2 libxi6
        elif command_exists dnf; then
            sudo dnf install -y mesa-libGL mesa-libGLU libX11 libXxf86vm libXrandr libXi
        elif command_exists yum; then
            sudo yum install -y mesa-libGL mesa-libGLU libX11 libXxf86vm libXrandr libXi
        elif command_exists pacman; then
            sudo pacman -S --noconfirm mesa glu libx11 libxxf86vm libxrandr libxi
        fi
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Graphics libraries installed${NC}"
        else
            echo -e "${YELLOW}! Some libraries may not have been installed. The game might not run properly.${NC}"
        fi
    else
        echo -e "${GREEN}✓ All required graphics libraries found${NC}"
    fi
fi

# Make build and run scripts executable
echo ""
echo "Making scripts executable..."
chmod +x build-linux.sh run-linux.sh 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Scripts are now executable${NC}"
fi

# Final summary
echo ""
echo "======================================"
echo -e "${GREEN}Setup completed!${NC}"
echo "======================================"
echo ""
echo "Next steps:"
if [ -n "$VIRTUAL_ENV" ]; then
    echo -e "${GREEN}✓ Virtual environment is active in this script${NC}"
    echo ""
    echo "To activate the virtual environment in your current shell:"
    echo -e "  ${YELLOW}source venv/bin/activate${NC}"
    echo ""
    echo "Then run the game:"
    echo -e "  ${YELLOW}./run-linux.sh${NC}"
elif [ "$IN_VENV" = true ]; then
    echo -e "${GREEN}✓ Virtual environment was activated during setup${NC}"
    echo ""
    echo "To use it in your current shell, run:"
    echo -e "  ${YELLOW}source venv/bin/activate${NC}"
    echo ""
    echo "Then run the game:"
    echo -e "  ${YELLOW}./run-linux.sh${NC}"
else
    echo "1. If you need to rebuild: ./build-linux.sh"
    echo "2. Run ./run-linux.sh to start the game"
fi
echo ""
