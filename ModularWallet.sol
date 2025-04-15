// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
import "@openzeppelin/contracts/access/Ownable.sol";

contract ModularWallet is Ownable{
     
    mapping(address=>bool) WhiteListPlugins;

    constructor() Ownable(msg.sender) {}

    event PluginAdded(address pluginAddress);
    event PluginRemoved(address pluginAddress);
    event PluginExecuted(address pluginAddress, bytes data);

    //@notice Function that allow  owner to add plugins Contract
    //@param Plugin's Contract Address 
    function addPlugin(address _pluginAddress) external onlyOwner {
         WhiteListPlugins[_pluginAddress] = true;
         emit PluginAdded(_pluginAddress);
    }

    //@notice Function that allow owner to remove plugin 
    //@param Plugin's Contract Address 
    function removePlugin(address _pluginAddress) external onlyOwner { 
        delete WhiteListPlugins[_pluginAddress];
        emit  PluginRemoved(_pluginAddress);
    }
    
    //@notice function to execute a Plugin, required a plugin to be added first, Only owner can call.
    //@param Plugin's Contract Address 
    //@param bytes data Abi encoded, including function signature and proper params
    function executePlugin(address _pluginAddress, bytes calldata _data) onlyOwner external returns(bool,bytes memory) { 
        require(WhiteListPlugins[_pluginAddress], "UnAuthorized Plugin");
        (bool success, bytes memory data) = _pluginAddress.delegatecall(_data);
        require(success,"Call Failed");
        emit PluginExecuted(_pluginAddress, _data);
        return (success,data);
    }

   receive() external payable { }
   
}



contract PluginX{ 
     function transferETH(address _recipient, uint amount) public {
            (bool success, bytes memory data) = payable(_recipient).call{value:amount}("");
             require(success,"Transfer Failed");
     }
}




