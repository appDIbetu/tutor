import 'package:bloc/bloc.dart';

class DashboardCubit extends Cubit<int> {
  DashboardCubit() : super(0); // Initial index is 0 (Home)

  void changeTab(int index) => emit(index);
}
