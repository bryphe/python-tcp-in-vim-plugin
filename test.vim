python << EOF
import threading
import Queue
import socket
import time
import json

class SocketListener:

    def __init__(self, ip, port):
        self.sock = None
        self.ip = ip
        self.port = port

    def startSocket(self):
        import socket 

        BUFFER_SIZE = 1

        if self.sock == None:
            self.messagesToSend = Queue.Queue()
            self.receivedMessages = Queue.Queue()
            self.stopEvent = threading.Event()

            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
            self.sock.connect((self.ip, self.port))

            self.receivedThread = threading.Thread(target = self._listenForMessages)
            self.sendThread = threading.Thread(target = self._sendMessages)
            self.receivedThread.start()
            self.sendThread.start()

    def stopSocket(self):
        import socket
        if self.sock == None:
            return

        print "closing"
        try:
            self.sock.shutdown(socket.SHUT_RDWR)
        except:
            pass
        self.stopEvent.set()
        self.sock.close()
        self.sock = None

    def sendMessage(self, msg):
        import json
        msg = json.dumps(msg)
        self.messagesToSend.put(msg)

    def getMessages(self):
        ret = []
        try:
            while True:
                message = self.receivedMessages.get_nowait()
                ret.append(message);
        except:
            pass
        return ret

    def _listenForMessages(self):
        while (not self.stopEvent.is_set()):
            try:
                message = self.messagesToSend.get_nowait()
                self.sock.send(message)
            except:
                pass
            self.stopEvent.wait(0.01)

    def _sendMessages(self):
        buffer = ""
        character = ""
        while (not self.stopEvent.is_set()):
            try:
                character = self.sock.recv(1)
            except:
                pass
            if '\n' in character:
                self.receivedMessages.put(buffer)
                buffer = ""
            else:
                buffer += character
            self.stopEvent.wait(0.01)

socket = SocketListener("127.0.0.1", 5005)
socket.startSocket()


def testSocket(*arg):
    socket.sendMessage(arg[0]);

def printMessages():
    try:
        while True:
            messages = receivedMessages.get_nowait()
            print messages
            return messages
    except:
        pass
EOF

function! PrintMessages()
python << EOF
for msg in socket.getMessages():
    print msg
EOF


endfunc

function! TestSocket(arg)

python << EOF
import vim
testSocket(vim.eval("a:arg"))
EOF
endfunc




command! -nargs=* MyCommand :python test(<f-args>)
command! -nargs=* TestSocket :call TestSocket(<f-args>)
command! -nargs=0 StartSocket :python socket.startSocket()
command! -nargs=0 StopSocket :python socket.stopSocket()
command! -nargs=0 PrintMessages :call PrintMessages(<f-args>)

autocmd VimLeavePre * :python socket.stopSocket()
