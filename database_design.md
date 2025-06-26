-----

### Legenda de Símbolos

  * **\<u\>sublinhado\</u\>**: Atributo faz parte da Chave Primária (PK).
  * **\*** (asterisco): Atributo é uma Chave Estrangeira (FK).

-----

### Esquema Relacional Normalizado e Ajustado

**CEP\_INFO** (`<u>cep</u>`, rua, bairro, cidade, estado)

**Usuario** (`<u>cpf</u>`, email, nome, descricao, cep\*, numero\_endereco)

  * `cep*` referencia `CEP_INFO(cep)`

**Dados\_Bancarios** (`<u>usuario_cpf</u>`\*, banco, agencia, conta)

  * `usuario_cpf*` referencia `Usuario(cpf)`

**Telefone** (`<u>usuario_cpf</u>`\*, `<u>telefone</u>`)

  * `usuario_cpf*` referencia `Usuario(cpf)`

**Espectador** (`<u>cpf_espectador</u>`\*)

  * `cpf_espectador*` referencia `Usuario(cpf)`

**Canal** (`<u>id_canal</u>`, nome\_canal, data\_criacao\_canal, descricao\_canal)

**Streamer** (`<u>cpf_streamer</u>`*, id\_canal*)

  * `cpf_streamer*` referencia `Usuario(cpf)`
  * `id_canal*` referencia `Canal(id_canal)`

**Categoria** (`<u>id_categoria</u>`, nome\_categoria, descricao\_categoria)

**Transmissao** (`<u>id_transmissao</u>`, titulo, status, data\_hora\_inicio, data\_hora\_termino, canal\_id\*, max\_espectadores\_simultaneos)

  * `canal_id*` referencia `Canal(id_canal)`

**Video** (`<u>id_video</u>`, titulo, descricao, duracao\_data\_upload, canal\_id\*)

  * `canal_id*` referencia `Canal(id_canal)`

**Clipe** (`<u>usuario_cpf</u>`*, `<u>id_transmissao</u>`*, `<u>data_criacao_clipe</u>`, titulo\_clipe, tempo\_clipe)

  * `usuario_cpf*` referencia `Usuario(cpf)`
  * `id_transmissao*` referencia `Transmissao(id_transmissao)`

**Indica** (`<u>indicador_cpf</u>`*, `<u>indicado_cpf</u>`*, data\_indicacao, comentario)

  * `indicador_cpf*` referencia `Usuario(cpf)`
  * `indicado_cpf*` referencia `Usuario(cpf)`

**Assina** (`<u>usuario_cpf</u>`*, `<u>canal_id</u>`*, nivel\_assinatura, data\_inicio, data\_fim)

  * `usuario_cpf*` referencia `Usuario(cpf)`
  * `canal_id*` referencia `Canal(id_canal)`

**Tem\_Categoria** (`<u>canal_id</u>`*, `<u>categoria_id</u>`*)

  * `canal_id*` referencia `Canal(id_canal)`
  * `categoria_id*` referencia `Categoria(id_categoria)`

**Avalia** (`<u>espectador_cpf</u>`*, `<u>transmissao_id</u>`*, nota, comentario)

  * `espectador_cpf*` referencia `Espectador(cpf_espectador)`
  * `transmissao_id*` referencia `Transmissao(id_transmissao)`

**Segue** (`<u>usuario_cpf</u>`*, `<u>canal_id</u>`*)

  * `usuario_cpf*` referencia `Usuario(cpf)`
  * `canal_id*` referencia `Canal(id_canal)`

**Assiste** (`<u>usuario_cpf</u>`*, `<u>video_id</u>`*, data\_assistido)

  * `usuario_cpf*` referencia `Usuario(cpf)`
  * `video_id*` referencia `Video(id_video)`

**Acompanha** (`<u>usuario_cpf</u>`*, `<u>transmissao_id</u>`*)

  * `usuario_cpf*` referencia `Usuario(cpf)`
  * `transmissao_id*` referencia `Transmissao(id_transmissao)`