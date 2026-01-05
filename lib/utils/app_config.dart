enum App { maaher, zar360 }
class AppConfig {

  static const App app = App.maaher;
  static const bool showIrankishLogo = false;


  static String getLogoPath() {
    if (app == App.zar360) {
      return 'assets/images/zar360.png';
    } else if (app == App.maaher) {
      return 'assets/images/maaher.png';
    } else {
      return 'assets/images/maaher.png';
    }
  }
}
