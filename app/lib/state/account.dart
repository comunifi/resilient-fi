import 'package:app/services/secure/secure.dart';
import 'package:flutter/cupertino.dart';

class AccountState with ChangeNotifier {
  // instantiate services here
  final SecureService _secureService = SecureService();

  // private variables here
  // final Config _config;
  // Config get config => _config;

  // constructor here
  // AppState(this._config)
  //     : currentTokenAddress = PreferencesService().tokenAddress != null
  //           ? _config.getToken(PreferencesService().tokenAddress!).address
  //           : _config.getPrimaryToken().address,
  //       currentTokenConfig = PreferencesService().tokenAddress != null
  //           ? _config.getToken(PreferencesService().tokenAddress!)
  //           : _config.getPrimaryToken(),
  //       lastAccount = PreferencesService().lastAccount;

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

  // state variables here
  // String? lastAccount;
  // String currentTokenAddress;
  // TokenConfig currentTokenConfig;

  // bool small = false;

  // Color get tokenPrimaryColor => currentTokenConfig.color ?? primaryColor;

  // state methods here
  // void setCurrentToken(String tokenAddress) {
  //   currentTokenAddress = tokenAddress;
  //   currentTokenConfig = _config.getToken(tokenAddress);

  //   _preferencesService.setToken(tokenAddress);
  //   safeNotifyListeners();
  // }

  // void setLastAccount(String account) {
  //   lastAccount = account;
  //   _preferencesService.setLastAccount(account);
  //   safeNotifyListeners();
  // }

  // void setSmall(bool small) {
  //   if (this.small == small) {
  //     return;
  //   }

  //   this.small = small;
  //   safeNotifyListeners();
  // }
}
