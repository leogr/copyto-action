FROM alpine/git:latest

LABEL "maintainer"="Leonardo Grasso <me@leonardograsso.com>"
LABEL "repository"="https://github.com/leogr/copyto-action"
LABEL "homepage"="https://github.com/leogr/copyto-action"

LABEL "com.github.actions.name"="CopyTo"
LABEL "com.github.actions.description"="Copy files from one repository to another."
LABEL "com.github.actions.icon"="upload-cloud"
LABEL "com.github.actions.color"="blue"

WORKDIR /copyto
ADD entrypoint.sh /copyto/entrypoint.sh
ENTRYPOINT ["/copyto/entrypoint.sh"]