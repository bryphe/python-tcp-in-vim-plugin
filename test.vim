pyfile socket.py
python << EOF
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
