0. We use homebrew for packages. If you'd like macports, refer to your macports documentation for syntax. 
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
   pip install enum                 # it's dependency of pythemis, but sometimes it doesn't 
   ```

6. Launch mongodb

   ```
   mongod --config /usr/local/etc/mongod.conf
   ```

7. Export path 

   ```
   set LD_LIBRARY_PATH=/usr/lib/
   set DYLD_FALLBACK_LIBRARY_PATH=/usr/lib/
   ```

8. Launch the server with -m <randompassword>

   ```
   python serv.py -m password123
   ```

9. Use iOS application to post smth to server, see history log by `http://127.0.0.1:8828/stat`