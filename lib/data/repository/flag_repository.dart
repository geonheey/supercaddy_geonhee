

// Abstract class remains unchanged
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/flag_model.dart';

abstract class AbstractFlagRepository {
  Future<List<FlagModel>> getFlagList(String plcNM);
}

// FlagRepository converted to use Riverpod
class FlagRepository implements AbstractFlagRepository {
  final FlagApi flagApi;

  FlagRepository({required this.flagApi});

  @override
  Future<List<FlagModel>> getFlagList(String plcNM) async {
    try {
      // Note: The original code had a bug where it called getFlags twice
      // I've fixed it to only call once and return the result
      final List<FlagModel> data = await flagApi.getFlags(plcNM);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> insertFlag(int hz, int vr, String nm, String unit) async {
    return flagApi.insertFlag(hz, vr, nm, unit);
  }
}

// Riverpod provider for FlagRepository
final flagRepositoryProvider = Provider<FlagRepository>((ref) {
  // Assuming FlagApi has its own provider
  final flagApi = ref.watch(flagApiProvider);
  return FlagRepository(flagApi: flagApi);
});

// Assuming FlagApi has its own provider, you'd need something like:
// final flagApiProvider = Provider<FlagApi>((ref) => FlagApi());