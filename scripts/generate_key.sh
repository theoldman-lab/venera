#!/bin/bash

set -e

echo "========================================"
echo "  生成 Android 签名密钥"
echo "========================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 Java 是否存在
if ! command -v keytool &> /dev/null; then
    echo -e "${RED}错误：未找到 keytool，请确保已安装 Java JDK${NC}"
    exit 1
fi

# 默认值
DEFAULT_ALIAS="venera"
DEFAULT_KEYPASS="venera123"
DEFAULT_STOREPASS="venera123"
DEFAULT_VALIDITY="10000"
DEFAULT_DNAME="CN=Venera, OU=Development, O=Venera, L=Unknown, ST=Unknown, C=Unknown"

echo "生成密钥库参数："
echo "  别名 (Alias): $DEFAULT_ALIAS"
echo "  密钥密码 (Key Password): $DEFAULT_KEYPASS"
echo "  密钥库密码 (Store Password): $DEFAULT_STOREPASS"
echo "  有效期 (Validity): $DEFAULT_VALIDITY 天"
echo ""

# 确认
read -p "是否使用默认参数生成密钥？(Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "请输入自定义参数："
    read -p "别名 (Alias) [$DEFAULT_ALIAS]: " alias
    alias=${alias:-$DEFAULT_ALIAS}
    
    read -p "密钥密码 (Key Password) [$DEFAULT_KEYPASS]: " -s keypass
    echo
    keypass=${keypass:-$DEFAULT_KEYPASS}
    
    read -p "密钥库密码 (Store Password) [$DEFAULT_STOREPASS]: " -s storepass
    echo
    storepass=${storepass:-$DEFAULT_STOREPASS}
    
    read -p "有效期 (Validity in days) [$DEFAULT_VALIDITY]: " validity
    validity=${validity:-$DEFAULT_VALIDITY}
else
    alias=$DEFAULT_ALIAS
    keypass=$DEFAULT_KEYPASS
    storepass=$DEFAULT_STOREPASS
    validity=$DEFAULT_VALIDITY
fi

# 创建密钥库目录
KEYSTORE_DIR="android/app"
KEYSTORE_FILE="$KEYSTORE_DIR/venera.keystore"

mkdir -p "$KEYSTORE_DIR"

echo ""
echo "正在生成密钥库..."

keytool -genkey -v \
    -keystore "$KEYSTORE_FILE" \
    -alias "$alias" \
    -keyalg RSA \
    -keysize 2048 \
    -validity "$validity" \
    -storepass "$storepass" \
    -keypass "$keypass" \
    -dname "$DEFAULT_DNAME"

echo -e "${GREEN}✓${NC} 密钥库已生成：$KEYSTORE_FILE"

# 创建 key.properties
KEY_PROPERTIES="android/key.properties"

echo ""
echo "正在创建 $KEY_PROPERTIES..."

cat > "$KEY_PROPERTIES" << EOF
storeFile=$KEYSTORE_FILE
storePassword=$storepass
keyAlias=$alias
keyPassword=$keypass
EOF

echo -e "${GREEN}✓${NC} 已创建 $KEY_PROPERTIES"

echo ""
echo "========================================"
echo "  密钥生成完成！"
echo "========================================"
echo ""
echo -e "${YELLOW}重要提示：${NC}"
echo "  1. 请妥善保管密钥库文件和密码"
echo "  2. 不要将密钥文件提交到版本控制系统"
echo "  3. 建议使用强密码替换默认密码"
echo ""
echo "下一步："
echo "  运行 './scripts/setup.sh' 完成环境配置"
echo "  或运行 'flutter build apk' 构建应用"
echo ""
