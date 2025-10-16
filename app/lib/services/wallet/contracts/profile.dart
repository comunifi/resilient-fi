import 'dart:async';
import 'dart:typed_data';

import 'package:app/services/config/config.dart';
import 'package:app/utils/uint8.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:smartcontracts/contracts/apps/Profile.g.dart';
import 'package:web3dart/web3dart.dart';

const String ipfsPrefix = 'ipfs://';

class ProfileRequest {
  String account;
  String username;
  String name;
  String description;

  ProfileRequest({
    this.account = '',
    this.username = '',
    this.name = '',
    this.description = '',
  });

  // from ProfileV1
  ProfileRequest.fromProfileV1(
    ProfileV1 profile, {
    this.account = '',
    this.username = '',
    this.name = '',
    this.description = '',
  }) {
    account = profile.account;
    username = profile.username;
    name = profile.name;
    description = profile.description;
  }

  // copy with
  ProfileRequest copyWith({
    String? account,
    String? username,
    String? name,
    String? description,
  }) {
    return ProfileRequest(
      account: account ?? this.account,
      username: username ?? this.username,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  // to json
  Map<String, dynamic> toJson() => {
    'account': account,
    'username': username,
    'name': name,
    'description': description,
  };
}

class ProfileV1 {
  String account;
  String username;
  String name;
  String description;
  String image;
  String imageMedium;
  String imageSmall;
  String? parent;

  ProfileV1({
    this.account = '',
    this.username = 'anonymous',
    this.name = 'Anonymous',
    this.description = '',
    this.image = 'assets/icons/profile.png',
    this.imageMedium = 'assets/icons/profile.png',
    this.imageSmall = 'assets/icons/profile.png',
    this.parent,
  });

  // card profile
  ProfileV1.cardProfile(this.account, this.username)
    : name = 'Card',
      description = '',
      image = 'assets/icons/card.png',
      imageMedium = 'assets/icons/card.png',
      imageSmall = 'assets/icons/card.png';

  // treasury profile
  ProfileV1.treasuryProfile(TokenConfig? tokenConfig)
    : account = '0x0000000000000000000000000000000000000000',
      username = tokenConfig?.symbol ?? 'treasury',
      name = tokenConfig?.name ?? 'Treasury',
      description = '',
      image = tokenConfig?.logo ?? 'assets/icons/profile.png',
      imageMedium = tokenConfig?.logo ?? 'assets/icons/profile.png',
      imageSmall = tokenConfig?.logo ?? 'assets/icons/profile.png';

  // from json
  ProfileV1.fromJson(Map<String, dynamic> json)
    : account = json['account'] ?? '',
      username = (json['username'] as String? ?? 'anonymous').replaceAll(
        '@',
        '',
      ),
      name = json['name'] ?? 'Anonymous',
      description = json['description'] ?? '',
      image = json['image'] ?? 'assets/icons/profile.png',
      imageMedium =
          json['image_medium'] ?? json['image'] ?? 'assets/icons/profile.png',
      imageSmall =
          json['image_small'] ?? json['image'] ?? 'assets/icons/profile.png',
      parent = json['parent'];

  // from map
  ProfileV1.fromMap(Map<String, dynamic> json)
    : account = json['account'] ?? '',
      username = json['username'] ?? 'anonymous',
      name = json['name'] ?? 'Anonymous',
      description = json['description'] ?? '',
      image = json['image'] ?? 'assets/icons/profile.png',
      imageMedium = json['image_medium'] ?? 'assets/icons/profile.png',
      imageSmall = json['image_small'] ?? 'assets/icons/profile.png',
      parent = json['parent'];

  // to json
  Map<String, dynamic> toJson() => {
    'account': account,
    'username': username,
    'name': name,
    'description': description,
    'image': image,
    'image_medium': imageMedium,
    'image_small': imageSmall,
    if (parent != null) 'parent': parent,
  };

  // with copy
  ProfileV1 copyWith({
    String? account,
    String? username,
    String? name,
    String? description,
    String? image,
    String? imageMedium,
    String? imageSmall,
    String? parent,
  }) {
    return ProfileV1(
      account: account ?? this.account,
      username: username ?? this.username,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      imageMedium: imageMedium ?? this.imageMedium,
      imageSmall: imageSmall ?? this.imageSmall,
      parent: parent ?? this.parent,
    );
  }

  void parseIPFSImageURLs(String url) {
    image = image.replaceFirst(ipfsPrefix, '$url/');
    imageMedium = imageMedium.replaceFirst(ipfsPrefix, '$url/');
    imageSmall = imageSmall.replaceFirst(ipfsPrefix, '$url/');
  }

  bool get isAnonymous =>
      username == 'anonymous' && name == 'Anonymous' && description == '';

  // check equality
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileV1 &&
          runtimeType == other.runtimeType &&
          account == other.account &&
          username == other.username &&
          name == other.name &&
          description == other.description &&
          image == other.image &&
          imageMedium == other.imageMedium &&
          imageSmall == other.imageSmall &&
          parent == other.parent;

  @override
  int get hashCode => super.hashCode;
}

class ProfileContract {
  final int chainId;
  final Web3Client client;
  final String addr;
  late Profile contract;
  late DeployedContract rcontract;

  ProfileContract(this.chainId, this.client, this.addr) {
    contract = Profile(
      address: EthereumAddress.fromHex(addr),
      chainId: chainId,
      client: client,
    );
  }

  Future<void> init() async {
    final abi = await rootBundle.loadString(
      'packages/smartcontracts/contracts/apps/Profile.abi.json',
    );

    final cabi = ContractAbi.fromJson(abi, 'Profile');

    rcontract = DeployedContract(cabi, EthereumAddress.fromHex(addr));
  }

  Future<String> getURL(String addr) async {
    return contract.get(EthereumAddress.fromHex(addr));
  }

  Future<String> getURLFromUsername(String username) async {
    return contract.getFromUsername(
      convertStringToUint8List(username, forcePadLength: 32),
    );
  }

  Uint8List setCallData(String addr, String username, String url) {
    final function = rcontract.function('set');

    return function.encodeCall([
      EthereumAddress.fromHex(addr),
      convertStringToUint8List(username, forcePadLength: 32),
      url,
    ]);
  }

  void dispose() {
    // _sub?.cancel();
  }
}
