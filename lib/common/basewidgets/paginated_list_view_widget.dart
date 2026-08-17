import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';


class PaginatedListViewWidget extends StatefulWidget {
  final ScrollController? scrollController;
  final Function(int? offset) onPaginate;
  final int? totalSize;
  final int? offset;
  final int? limit;
  final Widget itemView;
  final bool enabledPagination;
  final bool reverse;
  const PaginatedListViewWidget({
    super.key, required this.scrollController, required this.onPaginate, required this.totalSize,
    required this.offset, required this.itemView, this.enabledPagination = true, this.reverse = false,
    this.limit = 10,
  });

  @override
  State<PaginatedListViewWidget> createState() => _PaginatedListViewWidgetState();
}

class _PaginatedListViewWidgetState extends State<PaginatedListViewWidget> {
  int? _offset;
  late List<int?> _offsetList;
  bool _isLoading = false;

  int get _pageLimit {
    final int limit = widget.limit ?? 10;
    return limit > 0 ? limit : 10;
  }

  int get _pageCount {
    if (widget.totalSize == null) {
      return 0;
    }
    return (widget.totalSize! / _pageLimit).ceil();
  }

  @override
  void initState() {
    super.initState();

    _offset = 1;
    _offsetList = [1];

    widget.scrollController?.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
  }

  @override
  void didUpdateWidget(covariant PaginatedListViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalSize != widget.totalSize || oldWidget.offset != widget.offset) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final ScrollController? controller = widget.scrollController;
    if (controller == null || !controller.hasClients) {
      return;
    }

    final position = controller.position;
    if (position.maxScrollExtent <= 0) {
      return;
    }

    if (position.pixels >= position.maxScrollExtent - 80
        && widget.totalSize != null && !_isLoading && widget.enabledPagination) {
      if (mounted) {
        _paginate();
      }
    }
  }

  void _maybeLoadMore() {
    if (!mounted || _isLoading || widget.totalSize == null || !widget.enabledPagination) {
      return;
    }
    if (_offset == null || _offset! >= _pageCount) {
      return;
    }

    final ScrollController? controller = widget.scrollController;
    if (controller != null && controller.hasClients && controller.position.maxScrollExtent > 80) {
      return;
    }

    _paginate();
  }

  void _paginate() async {
    if (_isLoading || widget.totalSize == null || !widget.enabledPagination) {
      return;
    }
    if (_offset! < _pageCount && !_offsetList.contains(_offset! + 1)) {

      setState(() {
        _offset = _offset! + 1;
        _offsetList.add(_offset);
        _isLoading = true;
      });
      await widget.onPaginate(_offset);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
      }
    }else {
      if(_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.offset != null && !_isLoading) {
      _offset = widget.offset;
      if (!_offsetList.contains(_offset)) {
        _offsetList.add(_offset);
      }
    }

    return Column(children: [
      widget.reverse ? const SizedBox() : widget.itemView,

       widget.totalSize == null || _offset! >= _pageCount || _offsetList.contains(_offset!+1) ? const SizedBox() : Center(child: Padding(
        padding: (_isLoading ) ?  const EdgeInsets.all(Dimensions.paddingSizeSmall) : EdgeInsets.zero,
        child: _isLoading ? const CircularProgressIndicator() : const SizedBox(),
      )),

      widget.reverse ? widget.itemView : const SizedBox(),

    ]);
  }
}
