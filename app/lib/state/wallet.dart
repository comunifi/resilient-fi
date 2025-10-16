import 'dart:async';

import 'package:app/services/config/config.dart';
import 'package:app/services/config/service.dart';
import 'package:app/services/photos/photos.dart';
import 'package:app/services/secure/secure.dart';
import 'package:app/services/wallet/contracts/profile.dart';
import 'package:app/services/wallet/wallet.dart';
import 'package:app/utils/delay.dart';
import 'package:app/utils/random.dart';
import 'package:app/utils/uint8.dart';
import 'package:flutter/cupertino.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class WalletState extends ChangeNotifier {
  // instantiate services here - local storage, db, api, etc.

  final PhotosService _photosService = PhotosService();
  final SecureService _secureService = SecureService();
  final ConfigService _configService = ConfigService();
  late Config _config;

  final Completer readyCompleter = Completer<void>();

  // constructor here - you could pass a user id to the constructor and use it to trigger all methods with that user id
  WalletState() {
    init();
  }

  Future<void> init() async {
    final config = await _configService.getLocalConfig();
    if (config == null) {
      throw Exception('Community not found in local asset');
    }

    await config.initContracts();

    _config = config;

    readyCompleter.complete();
  }

  Future<void> ready() async {
    await readyCompleter.future;
  }

  // life cycle methods here
  bool _mounted = true;
  void safeNotifyListeners() {
    if (_mounted) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  // state variables here - things that are observable by the UI
  bool isLoading = false;
  EthereumAddress? account;
  String? balance;
  ProfileV1? profile;

  Future<void> loadAccount() async {
    try {
      isLoading = true;
      safeNotifyListeners();

      final credentials = _secureService.getCredentials();
      if (credentials == null) {
        throw Exception('No credentials found');
      }

      print(credentials.$1.length);
      print(hexToBytes(credentials.$1).length);

      final EthereumAddress owner = EthereumAddress.fromPublicKey(
        convertStringToUint8List(credentials.$1),
      );
      final privateKey = EthPrivateKey.fromHex(credentials.$2);

      final account = await _config.accountFactoryContract.getAddress(
        owner.hexEip55,
      );

      print(owner.hexEip55);
      print(account.hexEip55);

      this.account = account;

      balance = await getBalance(_config, account);
      safeNotifyListeners();

      final nonce = await _config.getNonce(account.hexEip55);
      if (nonce == BigInt.zero) {
        await createAccount(_config, account, privateKey);

        // set up profile
        final username = await _generateProfileUsername();
        if (username == null) {
          return;
        }

        profile = ProfileV1(account: account.hexEip55, username: username);

        final url = await setProfile(
          _config,
          account,
          privateKey,
          ProfileRequest.fromProfileV1(profile!),
          image: await _photosService.photoFromBundle(
            'assets/icons/profile.png',
          ),
          fileType: '.png',
        );
        if (url == null) {
          throw Exception('Failed to create profile url');
        }

        final newProfile = await getProfileFromUrl(_config, url);
        if (newProfile == null) {
          throw Exception('Failed to get profile from url $url');
        }

        profile = newProfile;
        safeNotifyListeners();
      }
    } catch (e, s) {
      debugPrint('Error loading account: $e');
      debugPrint('Stack trace: $s');
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  Future<String?> _generateProfileUsername() async {
    String username = await getRandomUsername();

    const maxTries = 3;
    const baseDelay = Duration(milliseconds: 100);

    for (int tries = 1; tries <= maxTries; tries++) {
      final exists = await profileExists(_config, username);

      if (!exists) {
        return username;
      }

      if (tries > maxTries) break;

      username = await getRandomUsername();
      await delay(baseDelay * tries);
    }

    return null;
  }
}
