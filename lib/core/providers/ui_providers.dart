import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI-related providers
class StickyNotifier extends Notifier<bool> {
	@override
	bool build() {
		return false;
	}

	void setSticky(bool v) => state = v;
	void setTrue() => state = true;
	void setFalse() => state = false;
}

final stickyOfflineProvider = NotifierProvider<StickyNotifier, bool>(StickyNotifier.new);
