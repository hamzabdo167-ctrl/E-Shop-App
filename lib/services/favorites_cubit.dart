import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesCubit extends Cubit<List<dynamic>> {
  FavoritesCubit() : super([]);

  void toggleFavorite(dynamic product) {
    final isExist = state.any((item) => item.id == product.id);
    if (isExist) {
      emit(state.where((item) => item.id != product.id).toList());
    } else {
      emit([...state, product]);
    }
  }

  bool isFavorite(dynamic product) {
    return state.any((item) => item.id == product.id);
  }
}
