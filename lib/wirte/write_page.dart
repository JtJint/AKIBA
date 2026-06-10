import 'dart:html' as html;

import 'package:akiba/app_router.dart';
import 'package:akiba/demand/api/wanted_api.dart';
import 'package:akiba/market/api/market_post_api.dart';
import 'package:akiba/media/api/media_api.dart';
import 'package:akiba/used/api/used_trade_api.dart';
import 'package:akiba/used/model/used_trade_models.dart';
import 'package:akiba/widgets/akiba_shell.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum WriteMode { used, wanted, auction, limited }

class WritePage extends StatefulWidget {
  const WritePage({
    super.key,
    this.initialMode,
    this.wantedEditPost,
    this.usedEditPost,
  });

  final WriteMode? initialMode;
  final WantedPostDetail? wantedEditPost;
  final UsedTradeItem? usedEditPost;

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
  String _limitedCondition = '미개봉';
  String _limitedSpecialType = 'LIMITED_EDITION';
  int _bidUnit = 1000;
  final int _categoryId = 1;
  bool _isSubmitting = false;

  DateTime _auctionDate = DateTime.now();
  TimeOfDay _auctionTime = TimeOfDay.now();
  static const int _maxImageCount = 8;
  final List<html.File> _imageFiles = [];
  final Map<html.File, String> _imagePreviewUrls = {};
  html.File? _receiptFile;

  bool get _isWantedEdit => widget.wantedEditPost != null;
  bool get _isUsedEdit => widget.usedEditPost != null;
  bool get _isEdit => _isWantedEdit || _isUsedEdit;

  @override
  void initState() {
    super.initState();
    _mode =
        widget.initialMode ??
        (_isUsedEdit ? WriteMode.used : null) ??
        (_isWantedEdit ? WriteMode.wanted : WriteMode.used);

    final wantedPost = widget.wantedEditPost;
    if (wantedPost != null) {
      _titleController.text = wantedPost.title;
      _descController.text = wantedPost.content;
      _priceController.text = wantedPost.price.toString();
      _wantedCondition = wantedPost.conditionTxt;
      _tradeMethod = wantedPost.deliveryMethod;
    }

    final usedPost = widget.usedEditPost;
    if (usedPost != null) {
      _titleController.text = usedPost.title;
      _descController.text = usedPost.description;
      _priceController.text = usedPost.price.toString();
      _itemCondition = usedPost.condition;
      _tradeMethod = usedPost.deliveryMethod;
      _purchasePlaceController.text = usedPost.purchaseSource;
      _tagController.text = usedPost.tags.join(' ');
    }
  }

  @override
  void dispose() {
    for (final objectUrl in _imagePreviewUrls.values) {
      html.Url.revokeObjectUrl(objectUrl);
    }
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

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final title = _titleController.text.trim();
    final content = _descController.text.trim();
    final priceText = _priceController.text.trim();
    final tags = _tagController.text
        .split(RegExp(r'[\s,]+'))
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .take(5)
        .toList();
    final price = int.tryParse(priceText);

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목과 설명을 입력해주세요.')));
      return;
    }

    if (_mode != WriteMode.auction && price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목, 설명, 가격을 올바르게 입력해주세요.')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final imageMediaIds =
          _existingImageMediaIdsIfEdit() ??
          await MediaApi.uploadAll(_imageFiles);
      final receiptMediaId = _receiptFile == null
          ? null
          : await MediaApi.upload(_receiptFile!);

      if ((_mode == WriteMode.used ||
              _mode == WriteMode.auction ||
              _mode == WriteMode.limited) &&
          imageMediaIds.isEmpty) {
        throw StateError('이미지를 1개 이상 추가해주세요.');
      }

      final response = switch (_mode) {
        WriteMode.wanted => await _submitWanted(
          title: title,
          content: content,
          price: price!,
          imageMediaIds: imageMediaIds,
          tagNames: tags,
        ),
        WriteMode.used => await _submitUsed(
          title: title,
          content: content,
          price: price!,
          receiptMediaId: receiptMediaId,
          imageMediaIds: imageMediaIds,
          tagNames: tags,
        ),
        WriteMode.auction => await _submitAuction(
          title: title,
          content: content,
          receiptMediaId: receiptMediaId,
          imageMediaIds: imageMediaIds,
          tagNames: tags,
        ),
        WriteMode.limited => await _submitLimited(
          title: title,
          content: content,
          price: price!,
          receiptMediaId: receiptMediaId,
          imageMediaIds: imageMediaIds,
          tagNames: tags,
        ),
      };

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isWantedEdit || _isUsedEdit ? '글이 수정되었습니다.' : '글이 등록되었습니다.',
            ),
          ),
        );
        if (_isWantedEdit || _isUsedEdit) {
          Navigator.of(context).pop();
        } else if (_mode == WriteMode.limited) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
          } else {
            Navigator.of(context).pushReplacementNamed(AppRouter.limited);
          }
        } else {
          Navigator.of(context).pushReplacementNamed('/main');
        }
        return;
      }

      debugPrint(
        'post create failed: mode=$_mode, status=${response.statusCode}, body=${response.body}',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('글 등록 실패 (${response.statusCode}): ${response.body}'),
        ),
      );
    } catch (error) {
      debugPrint('post create error: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('글 등록 중 오류가 발생했습니다: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  List<int>? _existingImageMediaIdsIfEdit() {
    if (_imageFiles.isNotEmpty) return null;
    if (_isWantedEdit) return widget.wantedEditPost!.imageMediaIds;
    if (_isUsedEdit) return widget.usedEditPost!.imageMediaIds;
    return null;
  }

  Future<http.Response> _submitWanted({
    required String title,
    required String content,
    required int price,
    required List<int> imageMediaIds,
    required List<String> tagNames,
  }) {
    final payload = WantedUpsertPayload(
      price: price,
      title: title,
      content: content,
      specialType: 'NONE',
      conditionTxt: _wantedCondition,
      deliveryMethod: _tradeMethod,
      imageMediaIds: imageMediaIds,
      tagNames: tagNames,
    );
    return _isWantedEdit
        ? WantedApi.updateWantedPost(
            postId: widget.wantedEditPost!.postId,
            payload: payload,
          )
        : WantedApi.createWantedPost(payload: payload);
  }

  Future<http.Response> _submitUsed({
    required String title,
    required String content,
    required int price,
    required int? receiptMediaId,
    required List<int> imageMediaIds,
    required List<String> tagNames,
  }) {
    final payload = UsedPostPayload(
      title: title,
      content: content,
      price: price,
      productCondition: _itemCondition,
      specialType: 'NONE',
      categoryId: _categoryId,
      deliveryMethod: _tradeMethod,
      purchaseSource: _purchasePlaceController.text.trim(),
      receiptMediaId: receiptMediaId ?? widget.usedEditPost?.receiptMediaId,
      imageMediaIds: imageMediaIds,
      tagNames: tagNames,
    );

    return _isUsedEdit
        ? UsedTradeApi.updatePost(
            postId: widget.usedEditPost!.id,
            payload: payload,
          )
        : MarketPostApi.createUsedPost(payload);
  }

  Future<http.Response> _submitAuction({
    required String title,
    required String content,
    required int? receiptMediaId,
    required List<int> imageMediaIds,
    required List<String> tagNames,
  }) {
    final startPrice = int.tryParse(_auctionStartPriceController.text.trim());
    if (startPrice == null) {
      throw StateError('경매 시작가를 올바르게 입력해주세요.');
    }
    final buyNowPrice = int.tryParse(_instantBuyPriceController.text.trim());
    final purchaseSource = _purchasePlaceController.text.trim();
    if (purchaseSource.isEmpty) {
      throw StateError('경매 구매처를 입력해주세요.');
    }
    if (receiptMediaId == null && widget.usedEditPost?.receiptMediaId == null) {
      throw StateError('경매 영수증 이미지를 추가해주세요.');
    }
    final endsAt = DateTime(
      _auctionDate.year,
      _auctionDate.month,
      _auctionDate.day,
      _auctionTime.hour,
      _auctionTime.minute,
    );

    return MarketPostApi.createAuctionPost(
      AuctionPostPayload(
        title: title,
        content: content,
        productCondition: _auctionCondition,
        specialType: 'NONE',
        categoryId: _categoryId,
        startPrice: startPrice,
        buyNowPrice: buyNowPrice,
        bidStep: _bidUnit,
        endsAt: endsAt,
        deliveryMethod: _tradeMethod,
        purchaseSource: purchaseSource,
        receiptMediaId: receiptMediaId,
        imageMediaIds: imageMediaIds,
        tagNames: tagNames,
      ),
    );
  }

  Future<http.Response> _submitLimited({
    required String title,
    required String content,
    required int price,
    required int? receiptMediaId,
    required List<int> imageMediaIds,
    required List<String> tagNames,
  }) {
    final purchaseSource = _purchasePlaceController.text.trim();
    if (purchaseSource.isEmpty) {
      throw StateError('구매처를 입력해주세요.');
    }

    return MarketPostApi.createLimitedPost(
      LimitedPostPayload(
        title: title,
        content: content,
        price: price,
        productCondition: _limitedCondition,
        specialType: _limitedSpecialType,
        categoryId: _categoryId,
        deliveryMethod: _tradeMethod,
        purchaseSource: purchaseSource,
        receiptMediaId: receiptMediaId,
        imageMediaIds: imageMediaIds,
        tagNames: tagNames,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AkibaShell(
      selectedIndex: 1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 20),
                if (!_isEdit) _buildModeSelector(),
                if (!_isEdit) const SizedBox(height: 18),
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
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffD0FF00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isSubmitting
                          ? '등록 중...'
                          : _isEdit
                          ? '수정 완료'
                          : '작성 완료',
                      style: const TextStyle(
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
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: IconButton(
          //     onPressed: () => Navigator.pop(context),
          //     icon: const Icon(Icons.close, color: Colors.white),
          //   ),
          // ),
          Center(
            child: Text(
              _isEdit ? '글 수정' : '글쓰기',
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
            DropdownMenuItem(
              value: WriteMode.limited,
              child: Text('특전/한정판'),
            ),
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
            _buildReceiptPicker(),
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
            _buildSectionLabel('가격 *'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _priceController,
              hintText: '₩ 가격을 입력해주세요.',
              keyboardType: TextInputType.number,
            ),
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
            _buildReceiptPicker(),
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

      case WriteMode.limited:
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
            _buildSectionLabel('특전/한정 구분 *'),
            const SizedBox(height: 8),
            _buildChoiceRow(
              values: const ['한정판', '특전', '특전/한정'],
              selectedValue: _limitedSpecialTypeLabel,
              onTap: (value) {
                setState(() {
                  _limitedSpecialType = _limitedSpecialTypeFromLabel(value);
                });
              },
            ),
            const SizedBox(height: 18),
            _buildSectionLabel('상태 *'),
            const SizedBox(height: 8),
            _buildChoiceRow(
              values: const ['개봉', '미개봉'],
              selectedValue: _limitedCondition,
              onTap: (value) {
                setState(() {
                  _limitedCondition = value;
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
            _buildSectionLabel('구매처 *'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _purchasePlaceController,
              hintText: '제품을 구매하신 링크를 입력해주세요.',
            ),
            const SizedBox(height: 18),
            _buildSectionLabel('영수증 인증'),
            const SizedBox(height: 8),
            _buildReceiptPicker(),
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

  String get _limitedSpecialTypeLabel {
    return switch (_limitedSpecialType) {
      'SPECIAL_BENEFIT' => '특전',
      'BOTH' => '특전/한정',
      _ => '한정판',
    };
  }

  String _limitedSpecialTypeFromLabel(String label) {
    return switch (label) {
      '특전' => 'SPECIAL_BENEFIT',
      '특전/한정' => 'BOTH',
      _ => 'LIMITED_EDITION',
    };
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final file in _imageFiles) ...[
                _buildImagePreview(file),
                const SizedBox(width: 8),
              ],
              if (_imageFiles.isEmpty) ...[
                _buildImageBox(isAdd: false),
                const SizedBox(width: 8),
              ],
              if (_imageFiles.length < _maxImageCount)
                GestureDetector(
                  onTap: _pickImages,
                  child: _buildImageBox(isAdd: true),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_imageFiles.length}/$_maxImageCount',
          style: const TextStyle(color: Color(0xff686868), fontSize: 12),
        ),
      ],
    );
  }

  String _previewUrlFor(html.File file) {
    return _imagePreviewUrls.putIfAbsent(
      file,
      () => html.Url.createObjectUrl(file),
    );
  }

  bool _isSameImageFile(html.File left, html.File right) {
    return left.name == right.name &&
        left.size == right.size &&
        left.lastModified == right.lastModified;
  }

  void _removeImageFile(html.File file) {
    final objectUrl = _imagePreviewUrls.remove(file);
    if (objectUrl != null) {
      html.Url.revokeObjectUrl(objectUrl);
    }
    setState(() {
      _imageFiles.remove(file);
    });
  }

  void _addImageFiles(List<html.File> files) {
    final nextFiles = [..._imageFiles];
    for (final file in files) {
      if (nextFiles.length >= _maxImageCount) break;
      final duplicated = nextFiles.any(
        (selectedFile) => _isSameImageFile(selectedFile, file),
      );
      if (!duplicated) {
        nextFiles.add(file);
      }
    }

    setState(() {
      _imageFiles
        ..clear()
        ..addAll(nextFiles);
    });
  }

  Widget _buildImagePreview(html.File file) {
    final objectUrl = _previewUrlFor(file);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xff1B1B1B),
            border: Border.all(color: const Color(0xff2F2F2F)),
          ),
          child: Image.network(objectUrl, fit: BoxFit.cover),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: () => _removeImageFile(file),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    if (_imageFiles.length >= _maxImageCount) return;
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = true;
    input.click();
    await input.onChange.first;

    final files = input.files ?? <html.File>[];
    if (files.isEmpty) return;
    _addImageFiles(files);
  }
  Future<void> _pickReceipt() async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    await input.onChange.first;

    final files = input.files ?? <html.File>[];
    if (files.isEmpty) return;
    setState(() {
      _receiptFile = files.first;
    });
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
          : const Icon(Icons.image_outlined, color: Colors.white38),
    );
  }

  Widget _buildReceiptPicker() {
    return InkWell(
      onTap: _pickReceipt,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xff111111),
          border: Border.all(color: const Color(0xff2F2F2F)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _receiptFile?.name ?? '영수증 이미지를 추가해주세요.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xff686868), fontSize: 13),
              ),
            ),
            const Icon(Icons.add, color: Colors.white),
          ],
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
