# Projeto de Banco de Dados para Plataforma de Streaming

Este projeto contém o esquema de um banco de dados relacional, normalizado até a 3ª Forma Normal (3FN), para uma plataforma de streaming de vídeo e lives, similar a serviços como Twitch ou YouTube.

## 🚀 Sobre o Projeto

O objetivo deste projeto foi modelar e construir uma base de dados robusta, consistente e escalável, capaz de gerenciar as principais entidades de uma plataforma de streaming, como usuários, canais, transmissões, vídeos, inscrições e interações da comunidade.

Todo o esquema foi desenvolvido utilizando SQL padrão, com ajustes para compatibilidade com o **Oracle Database**.

## ✨ Conteúdo do Repositório

* **Modelo Relacional Normalizado:** Documentação completa do esquema lógico.
* **Script de Criação de Tabelas (DDL):** Um script para criar todas as tabelas, sequências e restrições.
* **Script de Povoamento (DML):** Um script para inserir dados de amostra e testar o modelo.
* **Script de Limpeza:** Um script para deletar todas as tabelas do banco de dados.

## 🔧 Tecnologias Utilizadas

* **SQL**
* **Oracle Database**

## 📂 Estrutura e Como Usar

Os scripts no repositório devem ser executados na seguinte ordem para configurar e testar o ambiente corretamente:

1.  **`create_tables.sql`**
    * **O que faz?** Cria toda a estrutura de tabelas, chaves primárias, estrangeiras e outras restrições.
    * **Como usar?** Execute este script **primeiro** em um banco de dados Oracle limpo.

2.  **`populate.sql`**
    * **O que faz?** Popula as tabelas criadas com dados de amostra (usuários, canais, vídeos, etc.).
    * **Como usar?** Execute este script **após** a execução bem-sucedida do `create_tables.sql`.

3.  **`drop_tables.sql`**
    * **O que faz?** Remove **todas** as tabelas criadas, limpando completamente o ambiente.
    * **Como usar?** Use este script quando precisar resetar o banco de dados. Cuidado, esta ação é irreversível.

4.  **`database_design.md`**
    * **O que é?** Arquivo de documentação que descreve o esquema relacional normalizado, detalhando cada tabela, seus atributos e os relacionamentos. Consulte este arquivo para entender a lógica do modelo de dados.
