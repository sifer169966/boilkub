
![maintenance-status](https://img.shields.io/badge/maintenance-passively--maintained-yellowgreen.svg)

# Introduction
boilkub is a command interface that allows you to init a new project with a boiler-plate from a git repository on a remote server
## What's it used for

- Start a new project quickly

- Efficient use of local storage

- Agnostic repository provider

## Prerequisite

- [Homebrew](https://brew.sh/) installed

## Installation

```bash
brew tap sifer169966/homebrew-boilkub https://github.com/sifer169966/homebrew-boilkub
```

```bash
brew install boilkub
```


then try 
```bash
boilkub --version
``` 
you should see something like 
```shell
boilkub version <version> from source (https://github.com/sifer169966/boilkub)
```

Before using it, let’s prepare the default configuration for convenient usage. Open your terminal, then type this command below
```bash
cat <<EOF > ~/.boilkub/config/config
contexts:
  - context:
      project-url: https://example.com/golang-boilerplate.git
    name: go-hex
current-context: go-hex
EOF
```
## Usage

#### Set boilerplate

```bash
boilkub config set-context <context-name> --project-url=<boilerplate URL>.git
```

#### Retrieve boilerplate
```bash
boilkub config get-contexts
```

#### Change current context
```bash
boilkub config use-context <context-name>
```

#### Apply boilerplate 

```bash
boilkub apply
```


#### Use the current context and no prompt
```bash
boilkub apply -d <destination>
```

## Update to the latest version

pull the latest version of the tap

```bash
brew update
```

upgrade to the new version

```bash
brew upgrade boilkub
```

## Uninstallation

uninstall command

```bash
brew uninstall boilkub
```

remove brew tap

```bash
brew untap sifer169966/boilkub
```
---