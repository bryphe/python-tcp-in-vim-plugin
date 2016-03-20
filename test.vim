python << EOF
import threading
import Queue
import socket
import time

messagesToSend = Queue.Queue()
receivedMessages = Queue.Queue()
s = None

def listenForMessages(sock, stopEvent):
    while (not stopEvent.is_set()):
        try:
            message = messagesToSend.get_nowait()
            sock.send(message)
        except:
            pass
        stopEvent.wait(0.01)

def sendMessages(sock, stopEvent):
    buffer = ""
    character = ""
    while (not stopEvent.is_set()):
        try:
            character = sock.recv(1)
        except:
            pass
        if '\n' in character:
            receivedMessages.put(buffer)
            buffer = ""
        else:
            buffer += character
        stopEvent.wait(0.01)

threadStop = threading.Event()

def stopSocket():
    global s

    if s == None:
        return

    print "closing"
    try:
        s.shutdown(socket.SHUT_RDWR)
    except:
        pass
    threadStop.set()
    s.close()
    s = None

def startSocket():
        import json
        global s

        TCP_IP = "127.0.0.1"
        TCP_PORT = 5005
        BUFFER_SIZE = 1

        if s == None:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((TCP_IP, TCP_PORT))

            threadStop.clear()
            receivedThread = threading.Thread(target = listenForMessages, args=(s, threadStop,))
            sendThread = threading.Thread(target = sendMessages, args=(s, threadStop,))
            receivedThread.start()
            sendThread.start()

startSocket()

def testSocket(*arg):
    import json
    message = json.dumps(arg)
    messagesToSend.put(message)

def printMessages():
    try:
        while True:
            print receivedMessages.get_nowait()
    except:
        pass
EOF

function! TestSocket(arg)

python << EOF
import vim
testSocket(vim.eval("a:arg"))
EOF
endfunc


command! -nargs=* MyCommand :python test(<f-args>)
command! -nargs=* TestSocket :call TestSocket(<q-args>)
command! -nargs=0 StartSocket :python startSocket()
command! -nargs=0 StopSocket :python stopSocket()
command! -nargs=* PrintMessages :python printMessages(<f-args>)

