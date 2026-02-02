import 'package:flutter/material.dart';
import 'package:motus_lab/core/services/service_locator.dart';
import 'package:motus_lab/core/theme/app_colors.dart';
import 'package:motus_lab/features/scan/data/repositories/diagnostic_repository.dart';
import 'package:motus_lab/core/database/app_database.dart';
import 'package:motus_lab/features/scan/presentation/pages/expert/add_edit_dtc_page.dart';

class KnowledgeBasePage extends StatefulWidget {
  const KnowledgeBasePage({super.key});

  @override
  State<KnowledgeBasePage> createState() => _KnowledgeBasePageState();
}

class _KnowledgeBasePageState extends State<KnowledgeBasePage> {
  final _repository = locator<DiagnosticRepository>();
  String _searchQuery = "";
  List<DiagnosticIntelligenceData> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _repository.getAllIntelligence();
    setState(() {
      _items = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _items.where((item) {
      return item.dtcCode.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("Knowledge Base (คลังความรู้รถยนต์)"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Seed Data (Thailand)",
            onPressed: () async {
              await _repository
                  .seedFromAssets('assets/data/diagnostic_data_th.json');
              _loadData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBox(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _buildKnowledgeCard(item);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditDtcPage()),
          );
          if (result == true) _loadData();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "ค้นหา DTC (เช่น P0420)...",
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined,
              size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text("ยังไม่มีข้อมูลในคลังความรู้",
              style: TextStyle(color: Colors.white38)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await _repository
                  .seedFromAssets('assets/data/diagnostic_data_th.json');
              _loadData();
            },
            child: const Text("โหลดข้อมูลเริ่มต้น (Thailand)"),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeCard(DiagnosticIntelligenceData item) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(item.dtcCode,
            style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        subtitle: Text(
          item.vehicleModel ?? "ทุกรุ่นรถ (Universal)",
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditDtcPage(existingCode: item.dtcCode),
            ),
          );
          if (result == true) _loadData();
        },
      ),
    );
  }
}
