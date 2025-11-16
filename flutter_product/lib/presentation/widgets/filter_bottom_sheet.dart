// lib/presentation/widgets/filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _priceRange;
  late RangeValues _stockRange;

  late TextEditingController _priceMinCtrl;
  late TextEditingController _priceMaxCtrl;
  late TextEditingController _stockMinCtrl;
  late TextEditingController _stockMaxCtrl;

  late double _minPriceLimit;
  late double _maxPriceLimit;
  late double _minStockLimit;
  late double _maxStockLimit;

  @override
  void initState() {
    super.initState();
    final prov = context.read<ProductProvider>();

    _minPriceLimit = prov.minPrice;
    _maxPriceLimit = prov.maxPrice;
    _minStockLimit = prov.minStock.toDouble();
    _maxStockLimit = prov.maxStock.toDouble();

    double tempMin = prov.priceMinFilter ?? _minPriceLimit;
    double tempMax = prov.priceMaxFilter ?? _maxPriceLimit;
    _priceRange = RangeValues(tempMin, tempMax);

    int tempStockMin = prov.stockMinFilter ?? _minStockLimit.toInt();
    int tempStockMax = prov.stockMaxFilter ?? _maxStockLimit.toInt();
    _stockRange = RangeValues(tempStockMin.toDouble(), tempStockMax.toDouble());

    // --- FIX: Date range logic removed ---

    _priceMinCtrl = TextEditingController(text: tempMin.toStringAsFixed(2));
    _priceMaxCtrl = TextEditingController(text: tempMax.toStringAsFixed(2));
    _stockMinCtrl = TextEditingController(text: tempStockMin.toString());
    _stockMaxCtrl = TextEditingController(text: tempStockMax.toString());
  }

  @override
  void dispose() {
    _priceMinCtrl.dispose();
    _priceMaxCtrl.dispose();
    _stockMinCtrl.dispose();
    _stockMaxCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final prov = context.read<ProductProvider>();
    prov.setPriceFilter(_priceRange.start, _priceRange.end);
    prov.setStockFilter(_stockRange.start.toInt(), _stockRange.end.toInt());
    prov.setDateFilter(
      null,
      null,
    ); // --- FIX: Clear any existing date filter ---
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _priceMinCtrl.text = _minPriceLimit.toStringAsFixed(2);
      _priceMaxCtrl.text = _maxPriceLimit.toStringAsFixed(2);
      _stockMinCtrl.text = _minStockLimit.toInt().toString();
      _stockMaxCtrl.text = _maxStockLimit.toInt().toString();
      _priceRange = RangeValues(_minPriceLimit, _maxPriceLimit);
      _stockRange = RangeValues(_minStockLimit, _maxStockLimit);
      // --- FIX: Date range logic removed ---
    });
    context.read<ProductProvider>().clearFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final mediaH = MediaQuery.of(context).size.height;
    return SafeArea(
      child: SizedBox(
        height: mediaH * 0.75, // Adjust height as date filter is gone
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  const Text('Price Range'),
                  const SizedBox(height: 10),
                  _buildPriceFields(),
                  _buildPriceSlider(),
                  const SizedBox(height: 12),
                  const Text('Stock Range'),
                  const SizedBox(height: 10),
                  _buildStockFields(),
                  _buildStockSlider(),
                  const SizedBox(height: 24),
                  // --- FIX: Date filter section completely removed ---
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filters',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: _clearFilters,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text('Clear All'),
        ),
      ],
    );
  }

  Widget _buildPriceFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _priceMinCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: const InputDecoration(
              labelText: 'Min',
              prefixText: '\$ ',
              isDense: true,
            ),
            onChanged: (value) {
              final pMin = double.tryParse(value);
              if (pMin != null &&
                  pMin >= _minPriceLimit &&
                  pMin <= _priceRange.end) {
                setState(() {
                  _priceRange = RangeValues(pMin, _priceRange.end);
                });
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _priceMaxCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: const InputDecoration(
              labelText: 'Max',
              prefixText: '\$ ',
              isDense: true,
            ),
            onChanged: (value) {
              final pMax = double.tryParse(value);
              if (pMax != null &&
                  pMax <= _maxPriceLimit &&
                  pMax >= _priceRange.start) {
                setState(() {
                  _priceRange = RangeValues(_priceRange.start, pMax);
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSlider() {
    return RangeSlider(
      values: _priceRange,
      min: _minPriceLimit,
      max: _maxPriceLimit,
      divisions: 50,
      labels: RangeLabels(
        '\$${_priceRange.start.toStringAsFixed(2)}',
        '\$${_priceRange.end.toStringAsFixed(2)}',
      ),
      onChanged:
          (v) => setState(() {
            _priceRange = v;
            _priceMinCtrl.text = v.start.toStringAsFixed(2);
            _priceMaxCtrl.text = v.end.toStringAsFixed(2);
          }),
    );
  }

  Widget _buildStockFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _stockMinCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Min', isDense: true),
            onChanged: (value) {
              final sMin = int.tryParse(value);
              if (sMin != null &&
                  sMin >= _minStockLimit &&
                  sMin <= _stockRange.end) {
                setState(() {
                  _stockRange = RangeValues(sMin.toDouble(), _stockRange.end);
                });
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _stockMaxCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Max', isDense: true),
            onChanged: (value) {
              final sMax = int.tryParse(value);
              if (sMax != null &&
                  sMax <= _maxStockLimit &&
                  sMax >= _stockRange.start) {
                setState(() {
                  _stockRange = RangeValues(_stockRange.start, sMax.toDouble());
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStockSlider() {
    return RangeSlider(
      values: _stockRange,
      min: _minStockLimit,
      max: _maxStockLimit,
      divisions:
          (_maxStockLimit - _minStockLimit) > 0
              ? (_maxStockLimit - _minStockLimit).toInt()
              : 1,
      labels: RangeLabels(
        '${_stockRange.start.toInt()}',
        '${_stockRange.end.toInt()}',
      ),
      onChanged:
          (v) => setState(() {
            _stockRange = v;
            _stockMinCtrl.text = v.start.toInt().toString();
            _stockMaxCtrl.text = v.end.toInt().toString();
          }),
    );
  }

  // --- FIX: _buildDateFilter method removed ---

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: _applyFilters,
            child: const Text('Apply'),
          ),
        ),
      ],
    );
  }
}
