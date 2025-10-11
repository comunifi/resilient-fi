import 'package:dart_nostr/dart_nostr.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nostr_event.g.dart';

@JsonSerializable()
class NostrEventModel {
  final String id;
  final String pubkey;
  final int kind;
  final String content;
  final List<List<String>> tags;
  final String sig;
  final DateTime createdAt;

  const NostrEventModel({
    required this.id,
    required this.pubkey,
    required this.kind,
    required this.content,
    required this.tags,
    required this.sig,
    required this.createdAt,
  });

  factory NostrEventModel.fromNostrEvent(NostrEvent event) {
    return NostrEventModel(
      id: event.id ?? '',
      pubkey: event.pubkey ?? '',
      kind: event.kind ?? 1,
      content: event.content ?? '',
      tags: event.tags ?? [],
      sig: event.sig ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        ((event.createdAt as int?) ?? 0) * 1000,
      ),
    );
  }

  factory NostrEventModel.fromJson(Map<String, dynamic> json) =>
      _$NostrEventModelFromJson(json);

  Map<String, dynamic> toJson() => _$NostrEventModelToJson(this);

  NostrEvent toNostrEvent() {
    return NostrEvent(
      id: id,
      pubkey: pubkey,
      kind: kind,
      content: content,
      tags: tags,
      sig: sig,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'NostrEventModel(id: $id, pubkey: $pubkey, kind: $kind, content: $content, createdAt: $createdAt)';
  }
}
