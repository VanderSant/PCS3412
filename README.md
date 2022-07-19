# PCS3412
> Repositório para o trabalho final de Organização e Arquitetura de Computadores I
>
> [Repositório base](https://github.com/lucastrschneider/PCS3225)

## Organização do repositório 

Dentro das pastas `t_five_mc` e `t_five_mc` estão os arquivos relativos ao projeto dos dois processadores desenvolvidos, o T-FIVE Multiciclo e Pipeline, respectivamente.

Os arquivos que descrevem componentes devem ficar dentro da pasta `component`.

Os testbenches de cada componente devem ficar dentro da pasta `testbench` e deverão ser nomeados `<component>_tb`. Além disso, a entidade deve seguir o mesmo padrão de nomenclatura para evitar erros no Makefile.

Por fim, na pasta de cada um dos processadores há um arquivo `description.mk`. Ele deve conter uma lista com os arquivos da pasta `components` em ordem de prioridade (caso haja dependência entre eles), e uma variável para identificar o componente padrão que será usado nos testes.

```Makefile
# Name of all components in priority order
CPNT_LIST := multiplicador_fd multiplicador_uc multiplicador

# Name of the component to be tested
CPNT ?= multiplicador

# Commands to prepare test files
PREPARE_TEST :=
```

## Compilando e executando

Para compilar, é necessário ter instalado o [GHDL](https://github.com/ghdl/ghdl) e adicioná-lo ao PATH da shell utilizada.

Todos os comandos listados abaixo serão executados para um projeto específico, identificado pela variável `AT` do Makefile. Para mudar o projeto em que os comandos serão executados, basta mudar o valor padrão da variável para o nome da pasta do projeto atual. Também é possível fazer isso na chamada do comando, adicionando o novo valor da variável. Para executar o comando `make` no EP1, seria preciso fazer

```bash
make AT=t_five_mc
```

### Analisar
Para analisar os componentes e testbenches, execute o comando
```bash
make analyse
```
ou apenas
```bash
make
```

### Verificar sintaxe
Para apenas a sintaxe dos arquivos, execute
```bash
make check_syntax
```

### Limpar
Para limpar os arquivos gerados durante a compilação, execute
```bash
make clean
```

### Testar
Para testar, execute o comando
```bash
make test
```
Nesse caso, o componente que será testado é aquele com o nome salvo na variável `CPNT` de `description.mk`, assim, é possível mudar o componente padrão direto no arquivo de descrição do projeto (editando o valor inicial da variável), ou na linha de comando.

Além disso, para ver o resultado da simulação em um ambiente gráfico, utiliza-se a variável VISUAL=1. Note que para utilizar esse recurso, é preciso ter o GtkWave instalado no sistema.

Assim, para indicar precisamente qual o projeto utilizado, qual componente deverá ser testado e se o ambiente gráfico deve ou não ser aberto, é preciso executar

```bash
make test AT=t_five_mc CPNT=t_five_mc VISUAL=1
```
O componente `t_five_mc` será testado com a testbench `t_five_mc_tb` e o GtkWave será aberto para visualizar o resultado da simulação.

OBS: Para testar o CPNT=t_five_mc, é necessário executar o arquivo t_five_mc_tb, por isso o padrão de nomenclatura deve sempre ser seguido.

OBS2: É necessário analisar os componentes antes de testar, e após qualquer mudança também.

## Instalando o necessário

As dependências desse repositório podem ser instaladas manualmente ou executadas diretamente dentro de um container docker. Caso você não esteja usando linux, recomendo que use o dockerfile direto para facilitar.

### - Instalando manualmente
#### Make

Para instalar o Make, basta executar os seguintes comandos.

```bash
sudo apt-get install build-essential
```

#### GHDL e GtkWave

Para instalar o GtkWave e Ghdl, basta executar os seguintes comandos.

```bash
sudo apt update
sudo apt-get install ghdl gtkwave
```

### - Instalando com docker

Siga o guia oficial do *docker* e *docker-compose* para instalação clicando [aqui](https://docs.docker.com/engine/install/) 

Depois que o docker estiver instalado, basta executar para baixar a imagem docker e colocar o container no ar:

```bash
sudo chmod +x run run_docker.sh
./run_docker.sh
```

Feito isso, toda vez que for usar o repositório basta usar o comando:
```bash
./run_docker.sh
```