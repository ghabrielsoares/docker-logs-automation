#!/usr/bin/env bash

# Define a senha do usuário
USER_PASSWORD="12345"

# Função para executar comandos com sudo e senha automática
run_with_sudo() {
    echo "$USER_PASSWORD" | sudo -S bash -c "$1"
}

# Atualiza o sistema
run_with_sudo "apt update && apt upgrade -y"

# Instala dependências para Docker
run_with_sudo "apt-get install -y ca-certificates curl gnupg lsb-release"

# Adiciona chave GPG do Docker
run_with_sudo "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg"

# Configura repositório do Docker
ARCH=$(dpkg --print-architecture)
DISTRO=$(lsb_release -cs)
run_with_sudo "echo 'deb [arch=${ARCH} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu ${DISTRO} stable' > /etc/apt/sources.list.d/docker.list"

# Atualiza repositórios e instala Docker
run_with_sudo "apt update"
run_with_sudo "apt install -y docker-ce docker-ce-cli containerd.io"

# Verifica se o Docker foi instalado corretamente
if ! command -v docker &>/dev/null; then
    echo "Erro: Docker não foi instalado corretamente."
    exit 1
fi

# Inicia e habilita Docker
run_with_sudo "systemctl start docker"
run_with_sudo "systemctl enable docker"

# Faz download do Docker Compose
run_with_sudo "curl -SL https://github.com/docker/compose/releases/download/v2.30.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose"

# Torna o Docker Compose executável
run_with_sudo "chmod +x /usr/local/bin/docker-compose"
run_with_sudo "ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose"

# Verifica se o Docker Compose foi instalado corretamente
if ! command -v docker-compose &>/dev/null; then
    echo "Erro: Docker Compose não foi instalado corretamente."
    exit 1
fi

# Cria estrutura de pastas e arquivos
mkdir -p ./home/gabrielcs2/live/promtail/config live/promtail/position var/log
cat > ./home/gabrielcs2/live/promtail/config/config.yaml <<EOF
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /position/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
- job_name: system
  static_configs:
  - targets:
    - localhost
    labels:
      job: varlogs
      _path_: /logs/syslogs/*log
EOF

cat > live/docker-compose.yaml <<EOF
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
EOF

# Sobe os serviços com Docker Compose
run_with_sudo "docker-compose -f live/docker-compose.yaml up -d"

# Adiciona o usuário ao grupo do Docker
run_with_sudo "usermod -aG docker $USER"

echo "Instalação e configuração concluídas com sucesso!"
echo "!!! SE ESTIVER EM UM TERMINAL SSH, DESCONECTE OU FECHE O TERMINAL !!!"
echo "Você precisa reiniciar a sessão porque a associação de um usuário a um grupo no Linux só é aplicada após o processo de login ser reiniciado. Isso acontece porque o sistema associa os grupos do usuário ao processo de login no momento em que você entra na sessão. Quando você adiciona o usuário a um grupo, o sistema não reavalia essa associação automaticamente para processos já em execução."
echo "Alternativa à reinicialização"
echo "Se você não quer encerrar a sessão, pode usar o comando newgrp para iniciar um novo shell temporário com as associações de grupo atualizadas:"
echo "'newgrp docker'"
echo "Isso cria um novo shell onde o grupo docker está ativo. Nesse shell, você poderá executar comandos Docker sem precisar reiniciar a sessão.
Após isso, teste:"
echo "'docker ps'"