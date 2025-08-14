# Projeto de Banco de Dados para Plataforma de Streaming

Este projeto contém o esquema de um banco de dados relacional, normalizado até a 3ª Forma Normal (3FN), para uma plataforma de streaming de vídeo e lives, similar a serviços como Twitch ou YouTube. Além disso, inclui scripts e exemplos para manipulação de dados em MongoDB.

## 🚀 Sobre o Projeto

O objetivo deste projeto foi modelar e construir uma base de dados robusta, consistente e escalável, capaz de gerenciar as principais entidades de uma plataforma de streaming, como usuários, canais, transmissões, vídeos, inscrições e interações da comunidade.

Todo o esquema foi desenvolvido utilizando SQL padrão, com ajustes para compatibilidade com o **Oracle Database**. Também foram incluídos exemplos de manipulação de dados em **MongoDB** para cenários específicos.

## ✨ Conteúdo do Repositório

* **Modelo Relacional Normalizado:** Documentação completa do esquema lógico.
* **Script de Criação de Tabelas (DDL):** Um script para criar todas as tabelas, sequências e restrições.
* **Script de Povoamento (DML):** Um script para inserir dados de amostra e testar o modelo.
* **Script de Limpeza:** Um script para deletar todas as tabelas do banco de dados.
* **Consultas MongoDB:** Scripts e exemplos para manipulação de dados em MongoDB.

## 📂 Estrutura do Repositório

* `create_tables.sql`: Cria toda a estrutura de tabelas, chaves primárias, estrangeiras e outras restrições.
* `populate.sql`: Popula as tabelas criadas com dados de amostra (usuários, canais, vídeos, etc.).
* `drop_tables.sql`: Remove todas as tabelas criadas, limpando completamente o ambiente.
* `database_design.md`: Documentação detalhada do esquema relacional normalizado.
* `f1_creator_mongo.py`: Script Python para manipulação de dados no MongoDB.
* `mongo/`: Contém arquivos JSON e exemplos de consultas MongoDB.
  * `campeonato_f1_parcial.json`: Dados parciais do campeonato de F1.
  * `mongo_consultas.txt`: Exemplos de consultas MongoDB.
* `README.md`: Este arquivo, com instruções e detalhes do projeto.

## 🔧 Tecnologias Utilizadas

* **SQL**
* **Oracle Database**
* **MongoDB**
* **Python**

## 🛠️ Como Configurar e Executar

1. **Configuração do Banco de Dados Relacional (Oracle):**
   * Execute o script `create_tables.sql` em um banco de dados Oracle limpo para criar a estrutura de tabelas.
   * Em seguida, execute o script `populate.sql` para inserir dados de amostra.
   * Caso precise limpar o ambiente, utilize o script `drop_tables.sql`.

2. **Configuração do MongoDB:**
   * Certifique-se de que o MongoDB está instalado e em execução.
   * Utilize o script `f1_creator_mongo.py` para carregar e manipular os dados JSON no MongoDB.
   * Consulte os exemplos de consultas no arquivo `mongo/mongo_consultas.txt`.

## 📊 Exemplos de Consultas

### SQL

```sql
-- Exemplo de consulta para listar todos os usuários
SELECT * FROM usuarios;

-- Exemplo de consulta para buscar vídeos de um canal específico
SELECT * FROM videos WHERE canal_id = 1;
```

### MongoDB

```python
# Exemplo de consulta para listar todos os documentos na coleção
from pymongo import MongoClient

client = MongoClient('mongodb://localhost:27017/')
db = client['campeonato_f1']
collection = db['corridas']

for doc in collection.find():
    print(doc)
```

## 📝 Licença

Este projeto está licenciado sob a Licença MIT. Consulte o arquivo LICENSE para mais informações.
