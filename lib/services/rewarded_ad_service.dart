import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// RewardedAdService — إعلانات مكافأة (اختياري للمستخدم المجاني).
///
/// الاستخدام:
///   • "شاهد إعلاناً → احصل على بذرة إضافية"
///   • "شاهد إعلاناً → احصل على قالب خاص"
///
/// ⚠️ يجب استبدال Test Ad Unit IDs بمعرفاتك من AdMob.
class RewardedAdService {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  int _retryCount = 0;

  // ⚠️ AdMob Test IDs — استبدلها بمعرفاتك الحقيقية قبل النشر
  static const String _androidTestId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _iosTestId =
      'ca-app-pub-3940256099942544/1712485313';

  static String get _adUnitId {
    if (kDebugMode) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? _iosTestId
          : _androidTestId;
    }
    // TODO: استبدل بمعرفاتك الإنتاجية
    return defaultTargetPlatform == TargetPlatform.iOS
        ? 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'
        : 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';
  }

  /// تحميل إعلان مكافأة.
  Future<void> loadAd() async {
    if (_isLoading || _rewardedAd != null) return;
    _isLoading = true;

    try {
      await RewardedAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(
          nonPersonalizedAds: false,
        ),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isLoading = false;
            _retryCount = 0;
            debugPrint('[RewardedAd] Loaded');
          },
          onAdFailedToLoad: (error) {
            _isLoading = false;
            _retryCount++;
            debugPrint('[RewardedAd] Failed: ${error.message}');

            // إعادة المحاولة بعد تأخير
            if (_retryCount < 3) {
              Future.delayed(Duration(seconds: _retryCount * 5), loadAd);
            }
          },
        ),
      );
    } catch (e) {
      _isLoading = false;
      debugPrint('[RewardedAd] Exception: $e');
    }
  }

  /// عرض إعلان. يُستدعى `onReward` عند إكمال المشاهدة.
  Future<bool> showAd({
    required VoidCallback onReward,
    VoidCallback? onDismiss,
  }) async {
    final ad = _rewardedAd;
    if (ad == null) {
      // حاول التحميل أولاً
      await loadAd();
      return false;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadAd(); // حمّل التالي
        onDismiss?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        debugPrint('[RewardedAd] Show failed: ${error.message}');
      },
    );

    ad.show(onUserEarnedReward: (ad, reward) {
      debugPrint('[RewardedAd] Reward earned: ${reward.amount} ${reward.type}');
      onReward();
    });

    return true;
  }

  /// هل الإعلان جاهز للعرض؟
  bool get isReady => _rewardedAd != null;

  /// إلغاء وتحرير.
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
