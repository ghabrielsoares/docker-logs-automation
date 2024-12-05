# Instalação automatizada do Docker, Docker Compose, Grafana, Loki

Bem-vindo ao projeto de instalação automatizada! Use os botões abaixo para navegar pelo conteúdo:

- [🐳 Explicação do Docker e Docker Compose](#docker-e-docker-compose)
- [📑 Explicação do Código](#código)
- [🔽 Instalação](#instalação)
- [🔽 Resumo da Instalação](#resumo-da-instalação)

## Docker e Docker Compose

Imagine que você quer criar um bolo. Para fazer isso, você precisa de ingredientes, ferramentas, e um espaço na cozinha. Mas e se toda vez que você fosse fazer um bolo, alguém fornecesse para você um **kit completo**, com tudo que você precisa, já pronto e isolado, sem depender da sua cozinha estar organizada? Esse kit teria farinha, ovos, batedeira e tudo mais, em um pacote. Você só usa e pronto, sem complicações.

- **Docker**: É como um "kit de cozinha" portátil. Ele cria um ambiente isolado (chamado de **container**) com tudo que um aplicativo precisa para funcionar (sistema operacional, bibliotecas, código). Isso garante que ele vai rodar da mesma forma em qualquer lugar, seja no seu computador, em um servidor ou na nuvem.
  
- **Docker Compose**: Agora imagine que você quer fazer **vários bolos ao mesmo tempo** ou precisa de bolos diferentes para pessoas diferentes. Docker Compose é como uma **lista de receitas** (um arquivo de configuração) que organiza e coordena vários "kits" (containers) para trabalharem juntos. Ele facilita a montagem de aplicações complexas com múltiplas partes, como um bolo com recheio, cobertura e decoração, cada um vindo de um container separado.

---

#### Exemplo simples com analogia:

1. **Docker**:
   - Sem Docker: Instalar manualmente o Python no computador, baixar bibliotecas, e configurar tudo para rodar um script.
   - Com Docker: Você pega um "kit" pronto que já tem o Python, as bibliotecas, e o script configurados. Só roda o container, e pronto!
   
   ```
   docker run python:3.9 python -c "print('Olá, Docker!')"
   ```

2. **Docker Compose**:
   - Sem Compose: Você configura manualmente um servidor web, um banco de dados e garante que eles se conectem.
   - Com Compose: Usa um arquivo para descrever como eles devem funcionar juntos, e o Docker Compose cuida do resto.

   Arquivo `docker-compose.yml` simples:
   ```yaml
   version: '3.8'
   services:
     web:
       image: nginx
       ports:
         - "8080:80"
     database:
       image: mysql
       environment:
         MYSQL_ROOT_PASSWORD: senha123
   ```

   Com um comando (`docker-compose up`), você sobe o servidor web e o banco de dados funcionando juntos.

---

### Explicação Técnica: Ligando os Pontos

#### Docker: 
- Um **container** é uma instância leve e isolada de um ambiente. Ele compartilha o mesmo kernel do sistema operacional host, mas tem tudo o que precisa (binários, bibliotecas) empacotado para garantir portabilidade e reprodutibilidade.
- Ele utiliza **imagens**, que são snapshots imutáveis do ambiente configurado. Por exemplo, uma imagem do Python 3.9 garante que o código vai rodar sempre no mesmo ambiente, independente do sistema operacional.

Diagrama:
```
+------------------------------------+
|            Host OS                |
|  (Linux, Windows, macOS)          |
+------------------------------------+
| Docker Daemon                     |
| - Gerencia containers e imagens   |
+------------------------------------+
| Containers:                       |
|  +-------------+  +-------------+ |
|  | Python App  |  | Nginx Server | |
|  |  Python 3.9 |  |  HTTP Server | |
|  +-------------+  +-------------+ |
+------------------------------------+
```

#### Docker Compose:
- Enquanto o Docker lida bem com containers individuais, o Compose facilita o gerenciamento de **aplicações multicontainer**. Por exemplo:
  - Um container para o backend (Python).
  - Outro container para o banco de dados (MySQL).
  - Outro para o frontend (Nginx).
- O Compose usa um arquivo de configuração YAML para declarar os serviços, suas imagens, redes e volumes.

Diagrama:
```
docker-compose.yml
+-----------------------------+
|  Services                  |
|  +-----------------------+ |
|  |  Web (Nginx)          | |--> Exposto na porta 8080
|  +-----------------------+ |
|  +-----------------------+ |
|  |  Database (MySQL)     | |--> Interligado ao Web
|  +-----------------------+ |
+-----------------------------+
```

---

Com essa abordagem, você pode:
- Entender Docker como "kits de aplicativos isolados".
- Ver o Docker Compose como o "manual de como esses kits trabalham juntos".

---

## Código

Esse script é um **guia automatizado** para instalar e configurar o Docker, o Docker Compose e ferramentas relacionadas, como o Loki (para coleta de logs), Promtail (para envio de logs), e Grafana (para visualização). Ele faz isso utilizando comandos `bash`, com permissões administrativas (`sudo`) automatizadas.

Aqui está o resumo do que ele faz, passo a passo:

1. **Configura senha de administrador:**  
   Armazena uma senha de administrador (`sudo`) para evitar pedir toda hora durante o script.

2. **Atualiza o sistema:**  
   Garante que o sistema está atualizado, instalando pacotes necessários.

3. **Instala o Docker:**  
   - Baixa e configura o repositório oficial do Docker.  
   - Instala o Docker Engine e suas ferramentas auxiliares.

4. **Instala o Docker Compose:**  
   Baixa o binário oficial do Docker Compose e o torna executável.

5. **Configura serviços de log (Loki, Promtail e Grafana):**  
   - Cria pastas e arquivos de configuração para cada serviço.  
   - Gera um arquivo `docker-compose.yaml` que descreve como esses serviços devem funcionar juntos.

6. **Executa os serviços:**  
   Usa o Docker Compose para subir os serviços definidos.

7. **Ajusta permissões de usuário:**  
   Adiciona o usuário ao grupo `docker` para que ele possa usar o Docker sem `sudo`.

8. **Recomendações pós-instalação:**  
   Explica como reiniciar a sessão ou usar um comando (`newgrp docker`) para evitar problemas de permissões.

---

### Explicação Técnica e Detalhada

#### **1. Automatizando o Sudo**
O script define a função `run_with_sudo` para facilitar o uso de comandos `sudo` sem precisar digitar a senha repetidamente. Isso é feito com:
```bash
echo "$USER_PASSWORD" | sudo -S bash -c "$1"
```
Isso passa a senha armazenada na variável `USER_PASSWORD` para o comando `sudo`.

---

#### **2. Atualização do Sistema**
Este trecho atualiza a lista de pacotes e instala atualizações:
```bash
run_with_sudo "apt update && apt upgrade -y"
```
Ele garante que as bibliotecas estão atualizadas para evitar problemas de dependências.

---

#### **3. Instalação do Docker**
- Instala as dependências necessárias para adicionar repositórios seguros.
- Adiciona a chave GPG do repositório Docker para garantir autenticidade.
- Configura o repositório do Docker baseado na arquitetura do sistema (`dpkg --print-architecture`) e na versão do sistema (`lsb_release -cs`).

Instalação do Docker propriamente dita:
```bash
run_with_sudo "apt install -y docker-ce docker-ce-cli containerd.io"
```

Verifica a instalação:
```bash
if ! command -v docker &>/dev/null; then
    echo "Erro: Docker não foi instalado corretamente."
    exit 1
fi
```
Esse comando retorna um erro caso o Docker não esteja acessível.

---

#### **4. Instalação do Docker Compose**
O Compose é baixado diretamente do repositório oficial do GitHub:
```bash
run_with_sudo "curl -SL https://github.com/docker/compose/releases/download/v2.30.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose"
run_with_sudo "chmod +x /usr/local/bin/docker-compose"
run_with_sudo "ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose"
```
Aqui, ele:
- Baixa o binário.
- Torna-o executável.
- Cria um link simbólico para facilitar o uso.

---

#### **5. Configuração de Serviços (Loki, Promtail, Grafana)**
O script cria uma estrutura de pastas para organizar os arquivos de configuração:
```bash
mkdir -p ./home/gabrielcs2/live/promtail/config live/promtail/position var/log
```
Depois, ele usa o comando `cat` para criar os arquivos `config.yaml` (Promtail) e `docker-compose.yaml` (configuração de serviços).

##### **Arquivo `docker-compose.yaml`:**
```yaml
networks:
  loki:
    driver: bridge

services:
  promtail:
    image: grafana/promtail:latest
    ports: 
      - "9080:9080" 
    networks:
      - loki
    depends_on:
      - loki
    volumes:
      - "./promtail/config/config.yaml:/etc/promtail/config/config.yaml"
      - "./var/log:/logs/syslogs/"
      - "./promtail/position:/position"

  loki:
    image: grafana/loki:latest
    ports: 
      - "3100:3100" 
    command:
      - -config.file=/etc/loki/local-config.yaml
      - -print-config-stderr=true 
    networks:
      - loki

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    depends_on:
      - loki
    networks:
      - loki
```

Esse arquivo define os seguintes serviços:
- **Promtail:** Coleta logs do sistema e os envia para o Loki.
- **Loki:** Armazena logs recebidos.
- **Grafana:** Visualiza os logs armazenados no Loki.

As redes e volumes configurados permitem que os serviços interajam de forma isolada e eficiente.

---

#### **6. Subindo os Serviços**
```bash
run_with_sudo "docker-compose -f live/docker-compose.yaml up -d"
```
Aqui, ele sobe os serviços em **modo desacoplado** (`-d`), permitindo que eles rodem em segundo plano.

---

#### **7. Ajustando Permissões**
Adiciona o usuário ao grupo `docker` para permitir o uso do Docker sem `sudo`:
```bash
run_with_sudo "usermod -aG docker $USER"
```
A recomendação final explica que é necessário reiniciar a sessão ou usar o comando `newgrp` para que a mudança de grupo tenha efeito imediato.

---

### Diagrama de Execução

```plaintext
1. Atualiza o sistema: apt update/upgrade
2. Instala Docker e Docker Compose:
   - Docker Engine
   - Docker Compose (binário)
3. Configura serviços com Docker Compose:
   - Loki (armazenamento de logs)
   - Promtail (coleta de logs)
   - Grafana (visualização de logs)
4. Sobe os serviços:
   - docker-compose up -d
5. Ajusta permissões de usuário:
   - Adição ao grupo 'docker'
```

Essa estrutura automatiza a instalação e configuração, reduzindo erros manuais e facilitando o uso do Docker.

---

## Instalação
Considere que estou usando o Ubuntu Server.
É uma boa prática atualizar os pacotes do sistema para garantir que tudo esteja com as versões mais recentes e corrigidas.

Execute os seguintes comandos no terminal:

```bash
sudo apt update && sudo apt upgrade -y
```

- `sudo apt update`: Atualiza a lista de pacotes disponíveis nos repositórios.
- `sudo apt upgrade -y`: Faz a atualização de todos os pacotes instalados.

---

### 4. **Baixar o arquivo do repositório GitHub**
Você pode usar `wget` ou `curl` para baixar diretamente o arquivo bruto do GitHub, caso o repositório esteja público. Use o link bruto do arquivo, que pode ser acessado clicando em "Raw" no GitHub. Por exemplo:
```bash
wget https://raw.githubusercontent.com/ghabrielsoares/docker-logs-automation/main/instalacao.sh
```
Ou com `curl`:
```bash
curl -O https://raw.githubusercontent.com/ghabrielsoares/docker-logs-automation/main/instalacao.sh
```

---

### 5. **Tornar o script executável**
Agora, você precisa garantir que o script `install_docker_and_promtail.sh` tenha permissões de execução. Execute:

```bash
chmod +x install_docker_and_promtail.sh
```

- O comando `chmod +x` adiciona permissões de execução ao arquivo.

---

### 6. **Executar o script**
Finalmente, execute o script com o seguinte comando:

```bash
./install_docker_and_promtail.sh
```

Isso irá executar o script e iniciar o processo de instalação/configuração descrito nele.

---

## Resumo da Instalação

Para facilitar, aqui está um resumo rápido de tudo o que foi descrito acima:

```bash
sudo apt update && sudo apt upgrade -y
git --version
sudo apt install git -y
git clone <URL_DO_REPOSITORIO>
cd <PASTA_DO_REPOSITORIO>
chmod +x install_docker_and_promtail.sh
./install_docker_and_promtail.sh
```

Substitua `<URL_DO_REPOSITORIO>` e `<PASTA_DO_REPOSITORIO>` pelas informações reais do repositório.

Com isso, o seu script será baixado, tornado executável! 😊

