"""
修复 Ollama 模型配置问题
"""
import requests
import json


def fix_ollama_config():
    """修复 Ollama 配置，使用实际存在的模型"""
    
    ollama_host = "http://172.17.0.1:11434"
    
    print("=" * 60)
    print("OLLAMA 配置修复工具")
    print("=" * 60)
    print()
    
    # 1. 获取实际可用的模型
    print("🔍 检查 Ollama 中的模型...")
    try:
        response = requests.get(f"{ollama_host}/api/tags", timeout=5)
        if response.status_code == 200:
            models = response.json().get('models', [])
            if not models:
                print("❌ Ollama 中没有模型！")
                print("\n💡 请在宿主机上拉取模型：")
                print("   ollama pull qwen2.5:3b     # 推荐：快速中文模型")
                print("   ollama pull llama3.2:3b    # 推荐：快速英文模型")
                print("   ollama pull deepseek-r1    # 您当前的模型")
                return
            
            print(f"✅ 找到 {len(models)} 个模型：")
            for i, model in enumerate(models, 1):
                print(f"   {i}. {model['name']}")
                print(f"      大小: {model['size'] / (1024**3):.1f} GB")
                print(f"      家族: {model['details'].get('family', 'N/A')}")
            
            # 使用第一个模型进行验证
            test_model = models[0]['name']
            print(f"\n🧪 使用 '{test_model}' 进行连接测试...")
            
            # 测试模型是否真的可用
            test_response = requests.post(
                f"{ollama_host}/api/generate",
                json={
                    'model': test_model,
                    'prompt': 'test',
                    'stream': False,
                    'options': {
                        'num_predict': 1  # 只生成 1 个 token
                    }
                },
                timeout=30
            )
            
            if test_response.status_code == 200:
                print(f"✅ 模型 '{test_model}' 可以正常使用")
            else:
                print(f"⚠️  模型测试返回状态码: {test_response.status_code}")
            
            print("\n" + "=" * 60)
            print("📝 在 Dify Web UI 中配置 Ollama")
            print("=" * 60)
            print("\n步骤：")
            print("1. 打开 http://localhost:3000")
            print("2. 进入 Settings → Model Provider")
            print("3. 找到 Ollama 部分")
            print("4. 配置以下信息：")
            print(f"   Base URL: {ollama_host}")
            print("   API Key: ollama  (任意值)")
            print("\n5. ⚠️  重要：如果出现 '模型未找到' 错误")
            print("   这是 Dify 的验证机制问题，有两个解决方案：")
            print()
            print("   方案 A - 拉取常见模型（推荐）：")
            print("   在宿主机执行：")
            print("   ollama pull qwen2.5:3b")
            print("   或")
            print("   ollama pull llama3.2:3b")
            print()
            print("   方案 B - 直接保存配置：")
            print("   有些 Dify 版本会在保存时验证默认模型")
            print("   即使验证失败，配置可能已经保存")
            print("   尝试在工作流中直接选择您已有的模型")
            print()
            print(f"6. 创建工作流时，选择模型：{test_model}")
            
            # 提供一键拉取脚本
            print("\n" + "=" * 60)
            print("🚀 快速解决方案")
            print("=" * 60)
            print("\n在宿主机上执行以下命令拉取轻量级模型：")
            print()
            print("# 选项 1: 中文优化模型（推荐）")
            print("ollama pull qwen2.5:3b")
            print()
            print("# 选项 2: 英文优化模型")
            print("ollama pull llama3.2:3b")
            print()
            print("# 选项 3: 微软小模型")
            print("ollama pull phi3:mini")
            print()
            print("拉取后，Dify 的验证就会通过！")
            
        else:
            print(f"❌ 无法连接到 Ollama: {response.status_code}")
            
    except requests.exceptions.Timeout:
        print("❌ 连接超时")
        print("\n请确保：")
        print("1. Ollama 在宿主机运行")
        print("2. Ollama 监听 0.0.0.0:11434")
    except Exception as e:
        print(f"❌ 错误: {e}")


def show_current_models():
    """显示当前模型和推荐的操作"""
    ollama_host = "http://172.17.0.1:11434"
    
    try:
        response = requests.get(f"{ollama_host}/api/tags", timeout=5)
        if response.status_code == 200:
            models = response.json().get('models', [])
            
            print("\n" + "=" * 60)
            print("📊 模型分析")
            print("=" * 60)
            
            if models:
                print(f"\n当前已安装 {len(models)} 个模型：")
                for model in models:
                    name = model['name']
                    size_gb = model['size'] / (1024**3)
                    family = model['details'].get('family', 'unknown')
                    
                    # 判断模型类型
                    if 'deepseek-r1' in name.lower():
                        model_type = "推理模型（较慢，适合复杂任务）"
                    elif 'qwen' in name.lower():
                        model_type = "中文优化"
                    elif 'llama' in name.lower():
                        model_type = "通用模型"
                    else:
                        model_type = "其他"
                    
                    print(f"\n✓ {name}")
                    print(f"  类型: {model_type}")
                    print(f"  大小: {size_gb:.1f} GB")
                    print(f"  家族: {family}")
                
                print("\n💡 建议：")
                if len(models) == 1 and 'deepseek-r1' in models[0]['name'].lower():
                    print("您只有 DeepSeek-R1，这是一个推理模型，响应可能较慢。")
                    print("建议添加一个快速模型用于日常对话：")
                    print()
                    print("在宿主机执行：")
                    print("ollama pull qwen2.5:3b    # 1.9GB, 快速中文")
                    print("ollama pull llama3.2:3b   # 2.0GB, 快速英文")
            else:
                print("\n⚠️  没有找到任何模型")
                
    except Exception as e:
        print(f"无法获取模型列表: {e}")


if __name__ == '__main__':
    fix_ollama_config()
    show_current_models()
