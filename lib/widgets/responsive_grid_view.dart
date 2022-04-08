import 'package:flutter/material.dart';

class ResponsiveGridView extends StatelessWidget {
  const ResponsiveGridView({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all()
      ),
      child: HorizontalResponsiveGridViewWithControls(
        itemCount: 100,
        columnCount: 5,
        rowCount: 3,
        gap: 10.0,
        itemBuilder: (context, index){
          return Container(
            color: Colors.red,
            alignment: Alignment.center,
            child: Text((index+1).toString()),
          );
        },
        controlBuilder: (context, details){
          return [
            IconButton(
              onPressed: (){
                details.onPrev();
              },
              icon: const Icon(Icons.chevron_left),
            ),
            const VerticalDivider(color: Colors.transparent,),
            IconButton(
              onPressed: (){
                details.onNext();
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ];
        },
      ),
    );
  }
}


class HorizontalResponsiveGridViewWithControls extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int columnCount;
  final int rowCount;
  final double gap;
  final List<Widget> Function(BuildContext context, ControlDetails details)? controlBuilder;
  const HorizontalResponsiveGridViewWithControls({Key? key, required this.itemCount, required this.itemBuilder, required this.columnCount, required this.rowCount, required this.gap, this.controlBuilder,}) : super(key: key);

  @override
  State<HorizontalResponsiveGridViewWithControls> createState() => _HorizontalResponsiveGridViewWithControlsState();
}

class _HorizontalResponsiveGridViewWithControlsState extends State<HorizontalResponsiveGridViewWithControls> {

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if(_scrollController.hasClients){
        _pageWidth = _scrollController.position.extentInside;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _HorizontalGridViewWithControlsLayout(
      controller: _scrollController,
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
      columnCount: widget.columnCount,
      rowCount: widget.rowCount,
      gap: widget.gap,
      controlsSection: _buildControls(),
      controlsSectionHeight: 50.0,
    );
  }

  Widget _buildControls(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: widget.controlBuilder == null ? _buildDefaultControls() : _buildCustomControls(),
    );
  }

  List<Widget> _buildDefaultControls(){
    return [
      ElevatedButton(onPressed: _onPrevClick, child: const Icon(Icons.chevron_left)),
      const VerticalDivider(color: Colors.transparent,),
      ElevatedButton(onPressed: _onNextClick, child: const Icon(Icons.chevron_right)),
    ];
  }

  List<Widget> _buildCustomControls(){
    return widget.controlBuilder!(context, ControlDetails(onPrev: _onPrevClick, onNext: _onNextClick));
  }

  double _scrolledPos = 0;
  double _pageWidth = 0;

  void _onPrevClick(){
    if(_scrolledPos <= 0){
      _scrolledPos = 0;
      return;
    }
    _scrolledPos -= _pageWidth;
    _scrollAnimated();
  }

  void _onNextClick(){
    if(_scrolledPos >= _scrollController.position.maxScrollExtent){
      _scrolledPos = _scrollController.position.maxScrollExtent;
      return;
    }
    _scrolledPos += _pageWidth;
    _scrollAnimated();
  }

  void _scrollAnimated(){
    _scrollController.animateTo(_scrolledPos, duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
  }
}


class ControlDetails{
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const ControlDetails({required this.onPrev, required this.onNext,});
}







//create horizontal grid view with controls section
class _HorizontalGridViewWithControlsLayout extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int columnCount;
  final int rowCount;
  final double gap;
  final Widget controlsSection;
  final double controlsSectionHeight;
  final ScrollController controller;
  const _HorizontalGridViewWithControlsLayout({Key? key, required this.itemCount, required this.itemBuilder, required this.columnCount, required this.rowCount, required this.gap, required this.controlsSection, required this.controlsSectionHeight, required this.controller,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {

          final double _finalGap = gap;
          final int _gapsPerPage = (columnCount-1);
          final double _totalGapsPerPage = (_finalGap * _gapsPerPage);
          final double _columnWidth = (constraints.maxWidth - _totalGapsPerPage) / columnCount;

          final double _pages = itemCount / (rowCount * columnCount);

          final double _viewPortWidth = constraints.maxWidth + _finalGap;

          return _pages > 1 ? _buildGridViewWithControlsSection(_columnWidth, _viewPortWidth, context) : _buildGridViewOnly(_columnWidth, _viewPortWidth);
        },
      ),
    );
  }

  Widget _buildGridViewOnly(double itemWidth, double viewPortWidth){
    return _gridView(itemWidth, viewPortWidth);
  }

  Widget _buildGridViewWithControlsSection(double itemWidth, double viewPortWidth, BuildContext context,){
    return Column(
      children: [
        Expanded(child: _gridView(itemWidth, viewPortWidth)),
        SizedBox(
          height: controlsSectionHeight,
          width: double.infinity,
          child: SizedBox(
            height: controlsSectionHeight,
            child: controlsSection,
          ),
        ),
      ],
    );
  }

  Widget _gridView(double itemWidth, double viewPortWidth){
    return GridView.builder(
      controller: controller,
      itemCount: itemCount,
      scrollDirection: Axis.horizontal,
      physics: _CustomPageScrollPhysics(viewPortDimension: viewPortWidth),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: rowCount,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        mainAxisExtent: itemWidth,
      ),
      itemBuilder: itemBuilder,
    );
  }
}

//custom scroll physics by page
class _CustomPageScrollPhysics extends ScrollPhysics{

  final double viewPortDimension;
  const _CustomPageScrollPhysics({required this.viewPortDimension, ScrollPhysics? parent})
      : super(parent: parent);

  @override
  _CustomPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _CustomPageScrollPhysics(viewPortDimension: viewPortDimension, parent: buildParent(ancestor));
  }

  double _getPage(ScrollMetrics position) {
    return position.pixels / viewPortDimension;
  }

  double _getPixels(double page) {
    return page * viewPortDimension;
  }

  double _getTargetPixels(ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.001;
    } else if (velocity > tolerance.velocity) {
      page += 0.001;
    }
    return _getPixels(page.roundToDouble());
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) || (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      //when reach end and reach beginning
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);

    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity, tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
