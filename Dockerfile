# Use Oracle Linux 8 base image
FROM oraclelinux:8

# Install dependencies for Chrome and ChromeDriver
RUN yum install -y \
    wget \
    unzip \
    curl \
    libX11 \
    libXss \
    libappindicator-gtk3 \
    liberation-fonts \
    alsa-lib \
    nspr \
    nss \
    xorg-x11-server-Xvfb \
    xdg-utils \
    && yum clean all

# Install Google Chrome (stable version)
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /etc/pki/rpm-gpg/RPM-GPG-KEY-google \
    && echo "[google-chrome]" > /etc/yum.repos.d/google-chrome.repo \
    && echo "name=google-chrome" >> /etc/yum.repos.d/google-chrome.repo \
    && echo "baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64" >> /etc/yum.repos.d/google-chrome.repo \
    && echo "enabled=1" >> /etc/yum.repos.d/google-chrome.repo \
    && echo "gpgcheck=1" >> /etc/yum.repos.d/google-chrome.repo \
    && echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-google" >> /etc/yum.repos.d/google-chrome.repo \
    && yum install -y google-chrome-stable \
    && yum clean all

# Install Node.js and npm
RUN curl -sL https://rpm.nodesource.com/setup_18.x | bash - \
    && yum install -y nodejs \
    && yum clean all

# Script to get the latest ChromeDriver version compatible with installed Chrome
RUN CHROME_VERSION=$(google-chrome --version | grep -oP '\d+\.\d+\.\d+') \
    && CHROMEDRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_VERSION}") \
    && if [ -z "$CHROMEDRIVER_VERSION" ]; then \
         echo "Falling back to latest ChromeDriver version"; \
         CHROMEDRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE"); \
       fi \
    && wget -q "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" \
    && unzip chromedriver_linux64.zip -d /usr/local/bin/ \
    && rm chromedriver_linux64.zip \
    && chmod +x /usr/local/bin/chromedriver

# Copy local ChromeDriver binary from ./chromeTest to container
COPY ./chromeTest/chromedriver /usr/local/bin/chromedriver
RUN chmod +x /usr/local/bin/chromedriver \
    && ls -l /usr/local/bin/chromedriver # Verify binary exists

# Set environment variable for ChromeDriver
ENV CHROMEDRIVER_PATH=/usr/local/bin/chromedriver


# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy the rest of the project files
COPY . .

# Set environment variable for ChromeDriver
ENV CHROMEDRIVER_PATH=/usr/local/bin/chromedriver

# Command to run WDIO tests
CMD ["npx", "wdio", "run", "./wdio.conf.js"]
