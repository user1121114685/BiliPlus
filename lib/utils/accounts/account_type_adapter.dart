import 'package:bili_plus/models/common/account_type.dart';
import 'package:bili_plus/utils/extension.dart';
import 'package:hive/hive.dart';

class AccountTypeAdapter extends TypeAdapter<AccountType> {
  @override
  final int typeId = 10;

  @override
  AccountType read(BinaryReader reader) =>
      AccountType.values.getOrNull(reader.readByte()) ?? AccountType.main;

  @override
  void write(BinaryWriter writer, AccountType obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
