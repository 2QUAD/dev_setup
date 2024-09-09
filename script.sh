#!/bin/bash

#Verificar se o usuário é root

if [ "$(id -u)" -ne 0 ]; then
    echo -e "\033[1;31mVocê deve executar este script como root.\033[0m"
    exit 1
fi


# Função para instalar o PHP

  install_php() {
    echo -e "\033[1;34mIniciando a instalação do PHP e Laravel...\033[0m"
    
     # Instalar Apache
    echo -e "\033[1;34mInstalando Apache...\033[0m"
    if ! dnf install -y httpd; then
        echo -e "\033[1;31mErro ao instalar o Apache.\033[0m"
        exit 1
    fi

    echo -e "\033[1;34mIniciando e habilitando o Apache...\033[0m"
    systemctl start httpd
    systemctl enable httpd

    
    echo -e "\033[1;34mInstalando PHP e extensões...\033[0m"
    if ! dnf install -y php php-cli php-common php-mbstring php-xml php-pdo php-zip php-mysqlnd php-json php-curl; then
        echo -e "\033[1;31mErro ao instalar o PHP e as extensões necessárias.\033[0m"
        exit 1
    fi

    echo -e "\033[1;32mPHP instalado com sucesso.\033[0m"
   
   systemctl restart httpd

    # Instalar o Composer
    echo -e "\033[1;34mInstalando o Composer...\033[0m"
    if ! curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; then
        echo -e "\033[1;31mErro ao instalar o Composer.\033[0m"
        exit 1
    fi

    echo -e "\033[1;32mComposer instalado com sucesso.\033[0m"

    # Instalar Laravel globalmente com Composer
    echo -e "\033[1;34mInstalando Laravel globalmente...\033[0m"
    if ! composer global require laravel/installer; then
        echo -e "\033[1;31mErro ao instalar o Laravel.\033[0m"
        exit 1
    fi

     # Atualizar PATH para o Laravel
    export PATH="$HOME/.config/composer/vendor/bin:$PATH"
    echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> ~/.bashrc

    # Permissões de pasta para Laravel
    echo -e "\033[1;34mAjustando permissões para o Laravel...\033[0m"
    chown -R apache:apache /var/www
    chmod -R 775 /var/www

    echo -e "\033[1;32mLaravel instalado com sucesso.\033[0m"
    echo -e "\033[1;34mCrie um novo projeto Laravel com: laravel new nome_do_projeto\033[0m"
}


 # Função para instalar o PostgreSQL
    install_postgresql() {
    echo "Instalando PostgreSQL..."
    dnf install -y postgresql-server postgresql-contrib

    echo "Inicializando banco de dados do PostgreSQL..."
    postgresql-setup --initdb

    echo "Habilitando e iniciando o serviço PostgreSQL..."
    systemctl enable postgresql
    systemctl start postgresql

    
    echo -n "Digite o nome do usuário que deseja criar no PostgreSQL: "
    read pg_user

    echo -n "Digite o nome do banco de dados que deseja criar: "
    read pg_db

    # Verificar se o usuário já existe
    sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$pg_user'" | grep -q 1
    if [ $? -eq 0 ]; then
        echo "O usuário '$pg_user' já existe."
    else
        # Criar o usuário se não existir
        sudo -u postgres createuser "$pg_user"
        echo "Usuário '$pg_user' criado com sucesso."
    fi

    
    sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "$pg_db"
    if [ $? -eq 0 ]; then
        echo "O banco de dados '$pg_db' já existe."
    else
        
        sudo -u postgres createdb -O "$pg_user" "$pg_db"
        echo "Banco de dados '$pg_db' criado com sucesso."
    fi

    echo "Configuração concluída! Usuário '$pg_user' e banco de dados '$pg_db' criados."
}


# Menu interativo
while true; do
    echo "----------------------------------------------------"
    echo "Selecione o que deseja instalar:"
    echo "1) Instalar PHP"
    echo "2) Instalar Docker"
    echo -e "\033[1;34m3)\033[0m \033[1;32mInstalar PostgreSQL\033[0m"
    echo "4) Instalar MySQL"
    echo "5) Instalar Ruby on Rails"
    echo "6) Instalar Docker Compose"
    echo "7) Instalar PHP Composer"
    echo "8) Sair"
    echo "----------------------------------------------------"
    read -p "Digite o número da sua escolha: " escolha

    case $escolha in
        1)
            install_php
            ;;
        2)
            install_docker
            ;;
        3)
            install_postgresql
            ;;
        4)
            install_mysql
            ;;
        5)
            install_ruby_rails
            ;;
        6)
            install_docker_compose
            ;;
        7)
            install_composer
            ;;
        8)
            echo "Saindo..."
            break
            ;;
        *)
            echo "Opção inválida! Por favor, escolha uma opção válida."
            ;;
    esac
done

echo "Instalação concluída!"