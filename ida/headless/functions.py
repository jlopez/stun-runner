"""Function metadata in Spindizzy's `collect_all_functions` shape (its ida/utils/functions.py).

One record per function: start_ea, end_ea, name, size (body plus chunks), chunks (the tails),
xrefsTo (calling functions), xrefsFrom (called functions), leaf (calls nothing), exploreLeaf
(calls only named functions). Import only after `idapro`.
"""

from __future__ import annotations

from typing import Any

import ida_funcs
import idautils


def _callees(start: int, end: int, own: str) -> set[str]:
    out = set()
    for head in idautils.Heads(start, end):
        for ref in idautils.CodeRefsFrom(head, 1):
            callee = ida_funcs.get_func(ref)
            if callee is not None:
                name = ida_funcs.get_func_name(callee.start_ea)
                if name != own:
                    out.add(name)
    return out


def collect_all_functions() -> list[dict[str, Any]]:
    """Every function, ordered by start address."""
    records = []
    for start in idautils.Functions():
        func = ida_funcs.get_func(start)
        if func is None:
            continue
        name = ida_funcs.get_func_name(start)
        chunks = []
        tails = ida_funcs.func_tail_iterator_t(func)
        ok = tails.main()
        while ok:
            chunk = tails.chunk()
            if chunk.start_ea != func.start_ea or chunk.end_ea != func.end_ea:
                chunks.append([chunk.start_ea, chunk.end_ea])
            ok = tails.next()
        callers = set()
        for ref in idautils.CodeRefsTo(start, 1):
            caller = ida_funcs.get_func(ref)
            if caller is not None:
                callers.add(ida_funcs.get_func_name(caller.start_ea))
        callees = _callees(func.start_ea, func.end_ea, name)
        for chunk_start, chunk_end in chunks:
            callees |= _callees(chunk_start, chunk_end, name)
        records.append(
            {
                "start_ea": func.start_ea,
                "end_ea": func.end_ea,
                "name": name,
                "size": func.end_ea - func.start_ea + sum(e - s for s, e in chunks),
                "chunks": chunks,
                "xrefsTo": sorted(callers),
                "xrefsFrom": sorted(callees),
                "leaf": not callees,
                "exploreLeaf": False,
            }
        )
    explored = {r["name"] for r in records if not r["name"].startswith("sub_")}
    for r in records:
        r["exploreLeaf"] = r["leaf"] or all(c in explored for c in r["xrefsFrom"])
    return sorted(records, key=lambda r: r["start_ea"])
