import 'package:flutter/material.dart';

enum WriteMode { used, wanted, auction }

class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  WriteMode _mode = WriteMode.used;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _purchasePlaceController =
      TextEditingController();
  final TextEditingController _receiptController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _auctionStartPriceController =
      TextEditingController();
  final TextEditingController _instantBuyPriceController =
      TextEditingController();

  String _itemCondition = '미개봉';
  String _tradeMethod = '직거래';
  String _wantedCondition = '미개봉';
  String _auctionCondition = '미개봉';
  int _bidUnit = 1000;

  DateTime _auctionDate = DateTime.now();
  TimeOfDay _auctionTime = TimeOfDay.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _purchasePlaceController.dispose();
    _receiptController.dispose();
    _tagController.dispose();
    _auctionStartPriceController.dispose();
    _instantBuyPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickAuctionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _auctionDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xffD0FF00),
              surface: Color(0xff1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _auctionDate = picked;
      });
    }
  }

  Future<void> _pickAuctionTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _auctionTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xffD0FF00),
              surface: Color(0xff1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _auctionTime = picked;
      });
    }
  }

  void _submit() {
    debugPrint('mode: $_mode');
    debugPrint('title: ${_titleController.text}');
    debugPrint('desc: ${_descController.text}');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('작성 완료 클릭됨')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff141414),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 20),
                  _buildModeSelector(),
                  const SizedBox(height: 18),
                  _buildSectionLabel('이미지 *'),
                  const SizedBox(height: 8),
                  _buildImagePickerRow(),
                  const SizedBox(height: 18),
                  _buildSectionLabel('제목 *'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _titleController,
                    hintText: '제품명, 장르, 캐릭터 이름을 포함해 주세요.',
                  ),
                  const SizedBox(height: 18),
                  _buildSectionLabel('설명 *'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descController,
                    hintText:
                        '거래 글에 필요한 설명을 적어주세요.\n\n상태, 구성품, 하자 여부, 거래 조건 등을 자세히 적으면 좋아요.',
                    maxLines: 6,
                  ),
                  const SizedBox(height: 22),
                  _buildModeFields(),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffD0FF00),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '작성 완료',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          const Center(
            child: Text(
              '글쓰기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xff111111),
        border: Border.all(color: const Color(0xff3A3A3A)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<WriteMode>(
          value: _mode,
          dropdownColor: const Color(0xff1B1B1B),
          isExpanded: true,
          iconEnabledColor: Colors.white,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          items: const [
            DropdownMenuItem(value: WriteMode.used, child: Text('중고거래')),
            DropdownMenuItem(value: WriteMode.wanted, child: Text('구해요')),
            DropdownMenuItem(value: WriteMode.auction, child: Text('경매')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _mode = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildModeFields() {
    switch (_mode) {
      case WriteMode.used:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('가격 *'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _priceController,
              hintText: '₩ 가격을 입력해주세요.',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),
            _buildSectionLabel('상태 *'),
            const SizedBox(height: 8),
            _buildChoiceRow(
              values: const ['개봉', '미개봉'],
              selectedValue: _itemCondition,
              onTap: (value) {
                setState(() {
                  _itemCondition = value;
                });
              },
            ),
            const SizedBox(height: 18),
            _buildSectionLabel('거래 방식 *'),
            const SizedBox(height: 8),
            _buildChoiceRow(
              values: const ['택배', '직거래'],
              selectedValue: _tradeMethod,
              onTap: (value) {
                setState(() {
                  _tradeMethod = value;
                });
              },
            ),
            const SizedBox(height: 18),
            _buildSectionLabel('구매처'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _purchasePlaceController,
              hintText: '제품을 구매하신 링크를 입력해주세요.',
            ),
            const SizedBox(height: 18),
            _buildSectionLabel('영수증 인증'),
            const SizedBox(height: 8),
            _buildPlusBox(),
            const SizedBox(height: 18),
            _buildSectionLabel('태그'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _tagController,
              hintText: '# 키워드를 입력해주세요. (최대 5개)',
            ),
          ],
        );

      case WriteMode.wanted:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('희망 상태 *'),
            const SizedBox(height: 8),
            _buildChoiceRow(
              values: const ['개봉', '미개봉'],
              selectedValue: _wantedCondition,
              onTap: (value) {
                setState(() {
                  _wantedCondition = value;
                });
              },
            ),
            const SizedBox(height: 18),
            _buildSectionLabel('거래 방식 *'),
            const SizedBox(height: 8),
            _buildChoiceRow(
              values: const ['택배', '직거래'],
              selectedValue: _tradeMethod,
              onTap: (value) {
                setState(() {
                  _tradeMethod = value;
                });
              },
            ),
            const SizedBox(height: 18),
            _buildSectionLabel('태그'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _tagController,
              hintText: '# 키워드를 입력해주세요. (최대 5개)',
            ),
          ],
        );

      case WriteMode.auction:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('구매처 *'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _purchasePlaceController,
              hintText: '제품을 구매하신 링크를 입력해주세요.',
            ),
            const SizedBox(height: 18),
            _buildSectionLabel('영수증 인증 *'),
            const SizedBox(height: 8),
            _buildPlusBox(),
            const SizedBox(height: 18),
            _buildSectionLabel('경매 시작가 *'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _auctionStartPriceController,
              hintText: '₩ 경매 시작할 최소 가격을 입력해주세요.',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),
            _buildSectionLabel('즉시 구매가'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _instantBuyPriceController,
              hintText: '₩ 즉시 구매가를 입력해주세요.',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),
            _buildSectionLabel('입찰 단위 *'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [1000, 5000, 10000].map((value) {
                    return _buildPriceChip(
                      label:
                          '${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}원',
                      selected: _bidUnit == value,
                      onTap: () {
                        setState(() {
                          _bidUnit = value;
                        });
                      },
                    );
                  }).toList()..add(
                    _buildPriceChip(label: '+', selected: false, onTap: () {}),
                  ),
            ),
            const SizedBox(height: 18),
            _buildSectionLabel('기간 *'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTapField(
                    text:
                        '${_auctionDate.year}.${_auctionDate.month.toString().padLeft(2, '0')}.${_auctionDate.day.toString().padLeft(2, '0')}',
                    onTap: _pickAuctionDate,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTapField(
                    text: _auctionTime.format(context),
                    onTap: _pickAuctionTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_auctionDate.year}.${_auctionDate.month.toString().padLeft(2, '0')}.${_auctionDate.day.toString().padLeft(2, '0')} ${_auctionTime.format(context)} 종료 예정',
              style: const TextStyle(color: Color(0xff8D8D8D), fontSize: 12),
            ),
            const SizedBox(height: 18),
            _buildSectionLabel('상태 *'),
            const SizedBox(height: 8),
            _buildChoiceRow(
              values: const ['개봉', '미개봉'],
              selectedValue: _auctionCondition,
              onTap: (value) {
                setState(() {
                  _auctionCondition = value;
                });
              },
            ),
            const SizedBox(height: 18),
            _buildSectionLabel('거래 방식 *'),
            const SizedBox(height: 8),
            _buildChoiceRow(
              values: const ['택배', '직거래'],
              selectedValue: _tradeMethod,
              onTap: (value) {
                setState(() {
                  _tradeMethod = value;
                });
              },
            ),
            const SizedBox(height: 18),
            _buildSectionLabel('태그'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _tagController,
              hintText: '# 키워드를 입력해주세요. (최대 5개)',
            ),
          ],
        );
    }
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildImagePickerRow() {
    return Row(
      children: [
        _buildImageBox(isAdd: false),
        const SizedBox(width: 8),
        _buildImageBox(isAdd: true),
      ],
    );
  }

  Widget _buildImageBox({required bool isAdd}) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xff1B1B1B),
        border: Border.all(color: const Color(0xff2F2F2F)),
      ),
      child: isAdd
          ? const Icon(Icons.add, color: Colors.white70)
          : ClipRRect(
              child: Image.network(
                'https://picsum.photos/200',
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xff686868), fontSize: 13),
        filled: true,
        fillColor: const Color(0xff1B1B1B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: Color(0xff2F2F2F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: Color(0xff2F2F2F)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xffD0FF00)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildChoiceRow({
    required List<String> values,
    required String selectedValue,
    required ValueChanged<String> onTap,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) {
        final bool selected = selectedValue == value;
        return GestureDetector(
          onTap: () => onTap(value),
          child: Container(
            width: 72,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xff8E2BFF)
                  : const Color(0xff252525),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xffBDBDBD),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlusBox() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xff111111),
        border: Border.all(color: const Color(0xff2F2F2F)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '영수증 이미지를 추가해주세요.',
            style: TextStyle(color: Color(0xff686868), fontSize: 13),
          ),
          Icon(Icons.add, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildTapField({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: const Color(0xff1B1B1B),
          border: Border.all(color: const Color(0xff2F2F2F)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildPriceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xff2E2E2E) : const Color(0xff1B1B1B),
          border: Border.all(
            color: selected ? const Color(0xffD0FF00) : const Color(0xff2F2F2F),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xffD0FF00) : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
