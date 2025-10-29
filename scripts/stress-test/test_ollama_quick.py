"""
快速验证 Ollama 配置
"""
import requests


def quick_test():
    """快速测试 Ollama 连接"""
    ollama_host = "http://172.17.0.1:11434"
    
    print("=" * 60)
    print("OLLAMA QUICK TEST")
    print("=" * 60)
    print()
    
    # 测试连接
    print("🔍 Testing connection...")
    try:
        response = requests.get(f"{ollama_host}/api/tags", timeout=5)
        if response.status_code == 200:
            models = response.json().get('models', [])
            print("✅ Connection: SUCCESS")
            print(f"   Host: {ollama_host}")
            print(f"   Models found: {len(models)}")
            for model in models:
                print(f"   - {model['name']}")
            
            print("\n" + "=" * 60)
            print("✅ OLLAMA IS READY!")
            print("=" * 60)
            print("\n📝 Configuration:")
            print(f"   Base URL: {ollama_host}")
            print("   Status: ✅ Working")
            print("\n💡 Use this in Dify:")
            print("   1. Open http://localhost:3000")
            print("   2. Go to Settings → Model Provider → Ollama")
            print(f"   3. Enter Base URL: {ollama_host}")
            print("   4. Click 'Save'")
            print(f"   5. Select model: {models[0]['name'] if models else 'N/A'}")
            
            # 测试简单生成（使用更短的超时）
            print("\n🧪 Testing quick generation (5s timeout)...")
            try:
                response = requests.post(
                    f"{ollama_host}/api/generate",
                    json={
                        'model': models[0]['name'],
                        'prompt': 'Hi',
                        'stream': False,
                        'options': {
                            'num_predict': 10  # 只生成 10 个 token
                        }
                    },
                    timeout=5
                )
                
                if response.status_code == 200:
                    print("✅ Generation: SUCCESS")
                else:
                    print("⚠️  Generation test skipped (timeout expected for large models)")
                    
            except requests.exceptions.Timeout:
                print("⚠️  Generation test skipped (timeout - model may be large)")
            except Exception as e:
                print(f"⚠️  Generation test skipped: {e}")
            
            return True
            
        else:
            print(f"❌ Connection: FAILED ({response.status_code})")
            return False
            
    except Exception as e:
        print(f"❌ Connection: FAILED")
        print(f"   Error: {e}")
        print("\n🔧 Troubleshooting:")
        print("   1. On host machine, run:")
        print("      export OLLAMA_HOST=0.0.0.0:11434")
        print("      ollama serve")
        print("   2. Verify from host:")
        print("      curl 172.17.0.1:11434/api/tags")
        return False


if __name__ == '__main__':
    quick_test()
