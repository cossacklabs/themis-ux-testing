###Linux: 

1. Bootstrap your python environment and install system packages: 

   ```
   openssl-devel or libssl-dev
   mongodb
   ```
   
2. Install Themis: 

   ```
   git clone https://github.com/cossacklabs/themis.git
   cd themis
   sudo make install
   ```

3. Install Python packages: `pythemis`, `pymongo`, `event`, `enum`. 

4. After installing everything, go to `serv.py` and: 
   1. Comment line 'from themis import ...', as it's intended for mac users
   2. Uncomment line with 'from pythemis import ...', it will use system-installed PyThemis.


###Mac OS X: 

*Since installing PyThemis on Mac OS X is a process with more moving parts, we've outlined it for iOS developers wanting to launch the server to test XCode project in greater depth:*

0. We use [homebrew](http://brew.sh/) for packages. If you'd like macports, refer to your macports documentation for syntax. 
1. We assume you have python installed since you're on legitimate mac. 
2. Install mongodb, if you don't have one

   ```
   brew install mongodb
   ```

3. Have libressl / openssl + libssl-dev installed via 
   
   ```
   brew instal openssl
   ```

4. Make with custom paths to force it look at the odd paths where brew installs openssl: 

   ```
   make CRYPTO_ENGINE_INCLUDE_PATH=/usr/local/opt/openssl/include CRYPTO_ENGINE_LIB_PATH=/usr/local/opt/openssl/lib install
   ```

5. Install server dependencies: 

   ```
   pip install pythemis   
   pip install gevent
   pip install pymongo
   pip install enum                 # mac pythemis doesn't seem to force install it's dependencies yet
   ```

6. Launch mongodb

   ```
   mongod --config /usr/local/etc/mongod.conf
   ```

7. Export DYLD path to libthemis.dyld. 

   ```
   set DYLD_FALLBACK_LIBRARY_PATH=/usr/lib/
   ```

8. Launch the server with -m <randompassword>

   ```
   python serv.py -m password123
   ```

9. Use iOS application to talk to server smth to server, see history log on `http://127.0.0.1:8828/stat`
