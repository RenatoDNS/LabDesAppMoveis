import 'package:flutter/material.dart';

void main() {
  runApp(const ListaContatosApp());
}

// =====================================================================
// Aplicativo e tema
// =====================================================================

class ListaContatosApp extends StatelessWidget {
  const ListaContatosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Contatos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3949AB)),
      ),
      home: const TelaListaContatos(),
    );
  }
}

// =====================================================================
// Modelo
// =====================================================================

/// Representa um contato da agenda: nome, telefone e a URL da foto.
class Contato {
  final String nome;
  final String telefone;
  final String urlFoto;

  const Contato({
    required this.nome,
    required this.telefone,
    required this.urlFoto,
  });
}

// =====================================================================
// Dados pré-cadastrados
// =====================================================================

/// Os 5 contatos exibidos pelo aplicativo. Como não há tela de cadastro,
/// a lista é fixa e definida aqui mesmo no código.
const List<Contato> contatos = [
  Contato(
    nome: 'Ana Souza',
    telefone: '(31) 98765-4321',
    urlFoto: 'https://randomuser.me/api/portraits/women/44.jpg',
  ),
  Contato(
    nome: 'Vicenzo Oliveira',
    telefone: '(31) 99123-4567',
    urlFoto: 'https://randomuser.me/api/portraits/men/32.jpg',
  ),
  Contato(
    nome: 'Carla Mendes',
    telefone: '(31) 98456-7890',
    urlFoto: 'https://randomuser.me/api/portraits/women/68.jpg',
  ),
  Contato(
    nome: 'Renato Santos',
    telefone: '(31) 99876-5432',
    urlFoto: 'https://randomuser.me/api/portraits/men/75.jpg',
  ),
  Contato(
    nome: 'Silvana Ferreira',
    telefone: '(31) 98234-5678',
    urlFoto: 'https://randomuser.me/api/portraits/women/12.jpg',
  ),
];

// =====================================================================
// Foto do contato (widget reutilizável)
// =====================================================================

/// Foto redonda carregada da internet, usada tanto na lista quanto na
/// tela de detalhe (só muda o tamanho).
///
/// Enquanto a imagem baixa, mostra um indicador de progresso; se não for
/// possível carregá-la (ex.: sem internet), mostra um ícone de pessoa.
class FotoContato extends StatelessWidget {
  const FotoContato({super.key, required this.url, this.raio = 24});

  final String url;
  final double raio;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final diametro = raio * 2;

    return ClipOval(
      child: Container(
        width: diametro,
        height: diametro,
        color: cores.primaryContainer,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, imagem, progresso) {
            if (progresso == null) return imagem; // terminou de carregar
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
          errorBuilder: (context, erro, pilha) => Icon(
            Icons.person,
            size: raio,
            color: cores.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Tela principal: a lista de contatos
// =====================================================================

class TelaListaContatos extends StatelessWidget {
  const TelaListaContatos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contatos')),
      body: ListView.separated(
        itemCount: contatos.length,
        separatorBuilder: (context, indice) => const Divider(height: 1),
        itemBuilder: (context, indice) {
          final contato = contatos[indice];
          return ListTile(
            leading: FotoContato(url: contato.urlFoto),
            title: Text(contato.nome),
            subtitle: Text(contato.telefone),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Empilha a tela de detalhe, passando o contato tocado como
              // parâmetro do construtor.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaDetalheContato(contato: contato),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// =====================================================================
// Tela secundária: detalhe do contato
// =====================================================================

class TelaDetalheContato extends StatelessWidget {
  const TelaDetalheContato({super.key, required this.contato});

  final Contato contato;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      // O botão de voltar aparece sozinho, pois esta tela está no topo da
      // pilha do Navigator.
      appBar: AppBar(title: Text(contato.nome)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FotoContato(url: contato.urlFoto, raio: 80),
              const SizedBox(height: 24),
              Text(contato.nome, style: tema.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, color: tema.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(contato.telefone, style: tema.textTheme.titleMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
