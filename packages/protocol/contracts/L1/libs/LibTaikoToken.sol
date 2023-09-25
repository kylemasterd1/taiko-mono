// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.20;

import { AddressResolver } from "../../common/AddressResolver.sol";

import { TaikoData } from "../TaikoData.sol";
import { TaikoToken } from "../TaikoToken.sol";

library LibTaikoToken {
    error L1_INSUFFICIENT_TOKEN();

    function depositTaikoToken(
        TaikoData.State storage state,
        AddressResolver resolver,
        uint256 amount
    )
        internal
    {
        if (amount == 0) return;
        TaikoToken(resolver.resolve("taiko_token", false)).transferFrom(
            msg.sender, address(this), amount
        );
        unchecked {
            state.taikoTokenBalances[msg.sender] += amount;
        }
    }

    function withdrawTaikoToken(
        TaikoData.State storage state,
        AddressResolver resolver,
        uint256 amount
    )
        internal
    {
        if (amount == 0) return;
        if (state.taikoTokenBalances[msg.sender] < amount) {
            revert L1_INSUFFICIENT_TOKEN();
        }
        // Unchecked is safe per above check
        unchecked {
            state.taikoTokenBalances[msg.sender] -= amount;
        }

        TaikoToken(resolver.resolve("taiko_token", false)).transfer(
            msg.sender, amount
        );
    }

    function incrementTaikoTokenBalance(
        TaikoData.State storage state,
        AddressResolver resolver,
        address to,
        uint256 amount,
        bool mint
    )
        internal
    {
        if (amount == 0) return;
        if (mint) {
            TaikoToken(resolver.resolve("taiko_token", false)).mint(
                address(this), amount
            );
        }
        state.taikoTokenBalances[to] += amount;
    }

    function decrementTaikoTokenBalance(
        TaikoData.State storage state,
        AddressResolver resolver,
        address from,
        uint256 amount
    )
        internal
    {
        if (amount == 0) return;
        if (state.taikoTokenBalances[from] < amount) {
            TaikoToken(resolver.resolve("taiko_token", false)).transferFrom(
                from, address(this), amount
            );
        } else {
            unchecked {
                state.taikoTokenBalances[from] -= amount;
            }
        }
    }
}