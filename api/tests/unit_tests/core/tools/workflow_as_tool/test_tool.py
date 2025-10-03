import pytest

from core.app.entities.app_invoke_entities import InvokeFrom
from core.tools.__base.tool_runtime import ToolRuntime
from core.tools.entities.common_entities import I18nObject
from core.tools.entities.tool_entities import ToolEntity, ToolIdentity
from core.tools.errors import ToolInvokeError
from core.tools.workflow_as_tool.tool import WorkflowTool


def test_workflow_tool_should_raise_tool_invoke_error_when_result_has_error_field(monkeypatch: pytest.MonkeyPatch):
    """Ensure that WorkflowTool will throw a `ToolInvokeError` exception when
    `WorkflowAppGenerator.generate` returns a result with `error` key inside
    the `data` element.
    """
    entity = ToolEntity(
        identity=ToolIdentity(author="test", name="test tool", label=I18nObject(en_US="test tool"), provider="test"),
        parameters=[],
        description=None,
        has_runtime_parameters=False,
    )
    runtime = ToolRuntime(tenant_id="test_tool", invoke_from=InvokeFrom.EXPLORE)
    tool = WorkflowTool(
        workflow_app_id="",
        workflow_as_tool_id="",
        version="1",
        workflow_entities={},
        workflow_call_depth=1,
        entity=entity,
        runtime=runtime,
    )

    # needs to patch those methods to avoid database access.
    monkeypatch.setattr(tool, "_get_app", lambda *args, **kwargs: None)
    monkeypatch.setattr(tool, "_get_workflow", lambda *args, **kwargs: None)

    # replace `WorkflowAppGenerator.generate` 's return value.
    monkeypatch.setattr(
        "core.app.apps.workflow.app_generator.WorkflowAppGenerator.generate",
        lambda *args, **kwargs: {"data": {"error": "oops"}},
    )
    monkeypatch.setattr("libs.login.current_user", lambda *args, **kwargs: None)
    monkeypatch.setattr(
        WorkflowTool,
        "_resolve_user",
        lambda self, _user_id: type("DummyUser", (), {"id": _user_id, "is_authenticated": True})(),
        raising=False,
    )

    with pytest.raises(ToolInvokeError) as exc_info:
        # WorkflowTool always returns a generator, so we need to iterate to
        # actually `run` the tool.
        list(tool.invoke("test_user", {}))
    assert exc_info.value.args == ("oops",)


def test_workflow_tool_falls_back_to_user_resolver_when_no_current_user(monkeypatch: pytest.MonkeyPatch):
    entity = ToolEntity(
        identity=ToolIdentity(author="tester", name="work", label=I18nObject(en_US="work"), provider="prv"),
        parameters=[],
        description=None,
        has_runtime_parameters=False,
    )
    runtime = ToolRuntime(tenant_id="tenant-id", invoke_from=InvokeFrom.SERVICE_API)
    tool = WorkflowTool(
        workflow_app_id="app-id",
        workflow_as_tool_id="tool-id",
        version="1",
        workflow_entities={},
        workflow_call_depth=0,
        entity=entity,
        runtime=runtime,
    )

    # keep tool internals simple for the test
    monkeypatch.setattr(tool, "_get_app", lambda *_args, **_kwargs: object())
    monkeypatch.setattr(tool, "_get_workflow", lambda *_args, **_kwargs: object())
    monkeypatch.setattr(tool, "_transform_args", lambda tool_parameters, **_: (tool_parameters, []))

    captured: dict[str, str] = {}

    class DummyUser:
        id = "dummy-user"
        is_authenticated = True

    dummy_user = DummyUser()

    def fake_resolver(self, user_id: str):
        captured["user_id"] = user_id
        return dummy_user

    def fake_generate(self, *, user, **_kwargs):
        assert user is dummy_user
        return {"data": {"outputs": {}}}

    monkeypatch.setattr("core.app.apps.workflow.app_generator.WorkflowAppGenerator.generate", fake_generate)
    monkeypatch.setattr("core.tools.workflow_as_tool.tool.current_user", None)
    monkeypatch.setattr(WorkflowTool, "_resolve_user", fake_resolver, raising=False)

    result = list(tool.invoke("user-123", {}))

    assert captured["user_id"] == "user-123"
    assert len(result) == 2  # text + json outputs
