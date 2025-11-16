import 'package:flutter/material.dart';
import 'package:flutter_product/presentation/widgets/filter_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';

class SortControls extends StatelessWidget {
  final ProductProvider prov;
  const SortControls({Key? key, required this.prov}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('None'),
          checkmarkColor: Colors.white,
          selected: prov.sortBy == SortBy.none,
          selectedColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          labelStyle:
              prov.sortBy == SortBy.none
                  ? const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  )
                  : null,
          onSelected: (_) => prov.setSort(SortBy.none),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: Row(
            children: [
              Text(
                'Price  ',
                style:
                    prov.sortBy == SortBy.price
                        ? const TextStyle(color: Colors.white)
                        : null,
              ),
              if (prov.sortBy == SortBy.price)
                Icon(
                  prov.sortAsc ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 16,
                  color: Colors.white,
                ),
            ],
          ),
          checkmarkColor: Colors.white,
          selected: prov.sortBy == SortBy.price,
          selectedColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          onSelected:
              (_) => prov.setSort(
                SortBy.price,
                ascending: prov.sortBy == SortBy.price ? !prov.sortAsc : true,
              ),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: Row(
            children: [
              Text(
                'Stock  ',
                style:
                    prov.sortBy == SortBy.stock
                        ? const TextStyle(color: Colors.white)
                        : null,
              ),
              if (prov.sortBy == SortBy.stock)
                Icon(
                  prov.sortAsc ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 16,
                  color: Colors.white,
                ),
            ],
          ),
          checkmarkColor: Colors.white,
          selected: prov.sortBy == SortBy.stock,
          selectedColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
          onSelected:
              (_) => prov.setSort(
                SortBy.stock,
                ascending: prov.sortBy == SortBy.stock ? !prov.sortAsc : true,
              ),
        ),
        const Spacer(),
        Consumer<ProductProvider>(
          builder: (context, prov, child) {
            final bool filtersActive = prov.areFiltersActive;
            if (filtersActive) {
              return TextButton(
                onPressed: prov.clearFilters,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.clear, size: 18),
                    SizedBox(width: 4),
                    Text('Clear'),
                  ],
                ),
              );
            }
            return child!;
          },
          child: TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => const FilterBottomSheet(),
              );
            },
            icon: Icon(
              Icons.filter_list,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: Text(
              'Filters',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
