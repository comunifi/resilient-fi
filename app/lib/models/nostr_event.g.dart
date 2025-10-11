// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nostr_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NostrEventModel _$NostrEventModelFromJson(Map<String, dynamic> json) =>
    NostrEventModel(
      id: json['id'] as String,
      pubkey: json['pubkey'] as String,
      kind: (json['kind'] as num).toInt(),
      content: json['content'] as String,
      tags: (json['tags'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList(),
      sig: json['sig'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$NostrEventModelToJson(NostrEventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pubkey': instance.pubkey,
      'kind': instance.kind,
      'content': instance.content,
      'tags': instance.tags,
      'sig': instance.sig,
      'createdAt': instance.createdAt.toIso8601String(),
    };
