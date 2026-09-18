import 'package:final_project/services/api_services.dart';
import 'package:final_project/services/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ApiService apiService;

  ProductsCubit(this.apiService) : super(ProductsInitialState());

  void getProducts() async {
    emit(ProductsLoadingState());
    try {
      final products = await apiService.fetchProducts();
      emit(ProductsSuccessState(products));
    } catch (e) {
      emit(ProductsErrorState(e.toString()));
    }
  }
}
