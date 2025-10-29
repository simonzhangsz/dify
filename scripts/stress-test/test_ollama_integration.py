"""
测试 Ollama 集成
"""
import requests
import json


def test_ollama_direct():
    """直接测试 Ollama API"""
    print("🧪 Testing Ollama API directly...")
    
    ollama_host = "http://172.17.0.1:11434"
    
    # 测试模型列表
    try:
        response = requests.get(f"{ollama_host}/api/tags", timeout=5)
        if response.status_code == 200:
            models = response.json().get('models', [])
            print("✅ Connection successful!")
            print(f"   Available models: {len(models)}")
            for model in models:
                print(f"   - {model['name']}")
        else:
            print(f"❌ Failed to get models: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        return False
    
    # 测试生成
    print("\n🧪 Testing model generation...")
    try:
        model_name = models[0]['name'] if models else 'deepseek-r1:latest'
        response = requests.post(
            f"{ollama_host}/api/generate",
            json={
                'model': model_name,
                'prompt': '什么是大语言模型？请用一句话回答。',
                'stream': False
            },
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Generation successful!")
            print(f"   Model: {model_name}")
            print(f"   Response: {result.get('response', '')[:100]}...")
            return True
        else:
            print(f"❌ Generation failed: {response.status_code}")
            print(f"   Error: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Generation test failed: {e}")
        return False


def test_dify_ollama():
    """测试通过 Dify API 使用 Ollama"""
    print("\n🧪 Testing Ollama via Dify API...")
    print("⚠️  This requires Dify API server to be running and a workflow configured with Ollama")
    print("   To test manually:")
    print("   1. Start Dify API: cd /workspaces/dify.git/api && uv run gunicorn --bind 0.0.0.0:5001 --workers 4 --worker-class gevent app:app")
    print("   2. Open Web UI: http://localhost:3000")
    print("   3. Create a workflow using Ollama model")
    print("   4. Get API key from Settings → API Access")
    print("   5. Run the workflow via API")


def main():
    """主测试函数"""
    print("=" * 60)
    print("OLLAMA INTEGRATION TEST")
    print("=" * 60)
    print()
    
    # 直接测试 Ollama
    success = test_ollama_direct()
    
    if success:
        print("\n" + "=" * 60)
        print("✅ OLLAMA IS READY TO USE!")
        print("=" * 60)
        print("\n📝 Configuration Summary:")
        print("   - Ollama Host: http://172.17.0.1:11434")
        print("   - Connection: ✅ Working")
        print("   - Model Generation: ✅ Working")
        print("\n💡 Next Steps:")
        print("   1. Start Dify API server")
        print("   2. Configure Ollama in Dify Web UI")
        print("   3. Create workflows using Ollama models")
    else:
        print("\n" + "=" * 60)
        print("❌ OLLAMA SETUP INCOMPLETE")
        print("=" * 60)
        print("\n🔧 Troubleshooting:")
        print("   1. Ensure Ollama is running on host:")
        print("      ollama serve")
        print("   2. Ensure Ollama is listening on 0.0.0.0:")
        print("      export OLLAMA_HOST=0.0.0.0:11434")
        print("      ollama serve")
        print("   3. Verify connection from container:")
        print("      curl http://172.17.0.1:11434/api/tags")
    
    # Dify 集成说明
    test_dify_ollama()


if __name__ == '__main__':
    main()
