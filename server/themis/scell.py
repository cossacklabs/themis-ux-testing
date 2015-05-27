from exception import themis_exception;
from ctypes import *
themis = cdll.LoadLibrary('libthemis.dylib')

class scell_full(object):
    def __init__(self, key_):
	self.key=key_;

    def encrypt(self, message, context=None):
        if context==None:
            context_length=0;
        else:
            context_length=len(context);
	encrypted_message_length=c_int(0);
	if themis.themis_secure_cell_encrypt_full(self.key ,len(self.key), context, context_length, message, len(message), None, byref(encrypted_message_length)) != -4:
	    raise themis_exception("themis_secure_cell_encrypt_full (encrypted message length determination) error");
	encrypted_message=create_string_buffer(encrypted_message_length.value);
	if themis.themis_secure_cell_encrypt_full(self.key ,len(self.key), context, context_length, message, len(message), encrypted_message, byref(encrypted_message_length)) != 0:
	    raise themis_exception("themis_secure_cell_encrypt_full error");
	return string_at(encrypted_message, encrypted_message_length.value);

    def decrypt(self, message, context=None):
        if context==None:
            context_length=0;
        else:
            context_length=len(context);
	decrypted_message_length=c_int(0);
	if themis.themis_secure_cell_decrypt_full(self.key ,len(self.key), context, context_length, message, len(message), None, byref(decrypted_message_length)) != -4:
	    raise themis_exception("themis_secure_cell_decrypt_full (decrypted message length determination) error");
	decrypted_message=create_string_buffer(decrypted_message_length.value);
	if themis.themis_secure_cell_decrypt_full(self.key ,len(self.key), context, context_length, message, len(message), decrypted_message, byref(decrypted_message_length)) != 0:
	    raise themis_exception("themis_secure_cell_decrypt_full error");
	return string_at(decrypted_message, decrypted_message_length.value);

class scell_auto_split(object):
    def __init__(self, key_):
	self.key=key_;

    def encrypt(self, message):
	encrypted_message_length=c_int(0);
	context_length=c_int(0);
	if themis.themis_secure_cell_encrypt_auto_split(self.key ,len(self.key), None, 0, message, len(message), None, byref(context_length), None, byref(encrypted_message_length)) != -4:
	    raise themis_exception("themis_secure_cell_encrypt_auto_split (encrypted message and context length determination) error");
	encrypted_message=create_string_buffer(encrypted_message_length.value);
	context=create_string_buffer(context_length.value);
	if themis.themis_secure_cell_encrypt_auto_split(self.key ,len(self.key), None, 0, message, len(message), context, byref(context_length), encrypted_message, byref(encrypted_message_length)) != 0:
	    raise themis_exception("themis_secure_cell_encrypt_auto_split error");
	return (string_at(encrypted_message, encrypted_message_length.value), string_at(context, context_length));

    def decrypt(self, message, context):
	decrypted_message_length=c_int(0);
	res=themis.themis_secure_cell_decrypt_auto_split(self.key ,len(self.key), None, 0, message, len(message), context, len(context), None, byref(decrypted_message_length));
        if res!=-4:
	    raise themis_exception("themis_secure_cell_decrypt_auto_split (decrypted message length determination) error "+`res`);
	decrypted_message=create_string_buffer(decrypted_message_length.value);
	if themis.themis_secure_cell_decrypt_auto_split(self.key ,len(self.key), None, 0, message, len(message), context, len(context), decrypted_message, byref(decrypted_message_length)) != 0:
	    raise themis_exception("themis_secure_cell_decrypt_auto_split error");
	return string_at(decrypted_message, decrypted_message_length.value);

class scell_user_split(object):
    def __init__(self, key_):
	self.key=key_;

    def encrypt(self, message, context):
	encrypted_message_length=c_int(0);
	if themis.themis_secure_cell_encrypt_user_split(self.key ,len(self.key), message, len(message), context, context_length, None, byref(encrypted_message_length)) != -4:
	    raise themis_exception("themis_secure_cell_encrypt_user_split (encrypted message length determination) error");
	encrypted_message=create_string_buffer(encrypted_message_length.value);
	if themis.themis_secure_cell_encrypt_user_split(self.key ,len(self.key), message, len(message), context, context_length, encrypted_message, byref(encrypted_message_length)) != 0:
	    raise themis_exception("themis_secure_cell_encrypt_user_split error");
	return string_at(encrypted_message, encrypted_message_length.value);

    def decrypt(self, message, context):
	decrypted_message_length=c_int(0);
	if themis.themis_secure_cell_decrypt_user_split(self.key ,len(self.key), message, len(message), context, context_length, None, byref(decrypted_message_length)) != -4:
	    raise themis_exception("themis_secure_cell_decrypt_user_split (decrypted message length determination) error");
	decrypted_message=create_string_buffer(decrypted_message_length.value);
	if themis.themis_secure_cell_decrypt_user_split(self.key ,len(self.key), message, len(message), context, context_length, decrypted_message, byref(decrypted_message_length)) != 0:
	    raise themis_exception("themis_secure_cell_decrypt_user_split error");
	return string_at(decrypted_message, decrypted_message_length.value);
