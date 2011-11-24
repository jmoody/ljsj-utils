setenv SHELL "/bin/tcsh"
setenv CLICOLOR
setenv VISUAL vim
setenv EDITOR vim
set autolist
set filec
set history = 100
set savehist = 100
set correct = cmd
setenv PATH "/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

if ("`uname`" == "Darwin") then
    setenv JAVA_HOME "/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home"
    # we default to macports if /opt/local/bin exists
    if [ -d "/opt/local/bin" ]; then
        setenv PATH "/opt/local/bin"
        setenv PATH $PATH":/opt/local/lib/mysql5/bin"
        setenv PATH $PATH":/opt/local/apache2/bin"
        setenv PATH $PATH":/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
        setenv MANPATH "/opt/local/share/man:/usr/share/man"
    endif
else
    alias ls 'ls --color=auto'
    setenv JAVA_HOME "/usr/lib/jvm/java-1.5.0-sun/jre"
    limit filesize unlimited
    setenv PATH "/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
    setenv PATH $PATH":/usr/local/maven/bin"
    setenv PATH $PATH":/usr/local/tomcat/bin"
endif

if ("`/usr/bin/whoami`" == "root") then
    set prompt="[%m:%~] %n# "
    if ("`uname`" == "Darwin") then
        setenv PATH $PATH":/var/root/bin"
    else
       setenv PATH $PATH":/root/bin"
    endif
else
    set prompt="[%m:%~] %n% "
    setenv PATH $PATH":/home/`whoami`/bin"
endif
