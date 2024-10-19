import 'package:flutter/material.dart';
import 'package:nurbanhoney/common/common.dart';
import 'package:provider/provider.dart';

class BaseView<T extends BaseViewModel> extends StatelessWidget {
  const BaseView({
    super.key,
    required this.viewModel,
    required this.builder,
    this.loadingIndicatorHeight,
  });

  final T viewModel;
  final Widget Function(BuildContext context, T viewModel) builder;
  final double? loadingIndicatorHeight;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => viewModel,
      child: Consumer<T>(
        builder: (context, viewModel, child) {
          return LoadingIndicator(
            height: loadingIndicatorHeight,
            isLoading: viewModel.isLoading,
            child: builder(context, viewModel),
          );
        },
      ),
    );
  }
}
